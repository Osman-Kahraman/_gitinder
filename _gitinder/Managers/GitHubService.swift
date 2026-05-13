//
//  GitHubService.swift
//  _gitinder
//
//  Created by Osman Kahraman on 2026-05-05.
//

import Foundation
import SwiftUI

final class GitHubService {
    static func fetchRepos(
        query: String,
        token: String?,
        existing: [Repo],
        blacklistCheck: (Repo) -> Bool,
        onRateLimited: (() async -> Void)? = nil,
        retryCount: Int = 1
    ) async throws -> [Repo] {
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let randomPage = Int.random(in: 1...5)

        guard let url = URL(string:
            "https://api.github.com/search/repositories?q=\(encodedQuery)&sort=stars&order=desc&per_page=30&page=\(randomPage)"
        ) else {
            throw GitHubClientError.invalidURL
        }

        var request = URLRequest(url: url)
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")

        if let token = token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            if isRateLimited(response), retryCount > 0 {
                await onRateLimited?()
                try await Task.sleep(nanoseconds: 30_000_000_000)

                return try await fetchRepos(
                    query: query,
                    token: token,
                    existing: existing,
                    blacklistCheck: blacklistCheck,
                    onRateLimited: onRateLimited,
                    retryCount: retryCount - 1
                )
            }

            try validate(response)

            guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let items = json["items"] as? [[String: Any]] else {
                throw GitHubClientError.invalidResponse
            }

            let repos = items.compactMap { item -> Repo? in
                guard let name = item["name"] as? String else { return nil }

                return Repo(
                    name: name,
                    description: item["description"] as? String ?? "",
                    star: item["stargazers_count"] as? Int ?? 0,
                    fork: item["forks_count"] as? Int ?? 0,
                    issues: item["open_issues_count"] as? Int ?? 0,
                    lastUpdate: item["updated_at"] as? String ?? "",
                    languagesURL: item["languages_url"] as? String ?? "",
                    languages: [],
                    owner: (item["owner"] as? [String: Any])?["login"] as? String ?? ""
                )
            }

            let existingIDs = Set(existing.map { "\($0.owner)/\($0.name)" })
            return repos.filter { repo in
                !existingIDs.contains("\(repo.owner)/\(repo.name)") && !blacklistCheck(repo)
            }
        } catch let error as GitHubClientError {
            throw error
        } catch {
            throw GitHubClientError.network(error)
        }
    }

    static func fetchLanguages(urlString: String, token: String?) async throws -> [Language] {
        guard let url = URL(string: urlString) else {
            throw GitHubClientError.invalidURL
        }

        var request = URLRequest(url: url)
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")

        if let token = token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            try validate(response)

            guard let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Int] else {
                throw GitHubClientError.invalidResponse
            }

            let total = dict.values.reduce(0, +)
            return dict.map { key, value in
                Language(
                    name: key,
                    percentage: total > 0 ? (Double(value) / Double(total)) * 100 : 0,
                    color: Color(
                        hue: Double.random(in: 0...1),
                        saturation: 0.7,
                        brightness: 0.9
                    )
                )
            }
        } catch let error as GitHubClientError {
            throw error
        } catch {
            throw GitHubClientError.network(error)
        }
    }

    static func fetchUserRepos(username: String) async throws -> [Repo] {
        guard let url = URL(string:
            "https://api.github.com/users/\(username)/repos?per_page=100&sort=updated"
        ) else {
            throw GitHubClientError.invalidURL
        }

        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            try validate(response)

            guard let json = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
                throw GitHubClientError.invalidResponse
            }

            return json.compactMap { item -> Repo? in
                guard let name = item["name"] as? String else { return nil }

                return Repo(
                    name: name,
                    description: item["description"] as? String ?? "",
                    star: item["stargazers_count"] as? Int ?? 0,
                    fork: item["forks_count"] as? Int ?? 0,
                    issues: item["open_issues_count"] as? Int ?? 0,
                    lastUpdate: item["updated_at"] as? String ?? "",
                    languagesURL: item["languages_url"] as? String ?? "",
                    languages: [],
                    owner: username
                )
            }
        } catch let error as GitHubClientError {
            throw error
        } catch {
            throw GitHubClientError.network(error)
        }
    }

    private static func validate(_ response: URLResponse) throws {
        guard let http = response as? HTTPURLResponse else {
            throw GitHubClientError.invalidResponse
        }

        switch http.statusCode {
        case 200...299:
            return
        case 401:
            throw GitHubClientError.unauthorized
        case 403:
            throw GitHubClientError.rateLimited
        case 500...599:
            throw GitHubClientError.serverError(http.statusCode)
        default:
            throw GitHubClientError.invalidResponse
        }
    }

    private static func isRateLimited(_ response: URLResponse) -> Bool {
        guard let http = response as? HTTPURLResponse else { return false }
        return http.statusCode == 403
    }
}
