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

        let request = try GitHubHTTPClient.makeRequest(urlString: url.absoluteString, token: token)

        let (data, response) = try await GitHubHTTPClient.rawData(for: request)

        if GitHubHTTPClient.isRateLimited(response), retryCount > 0 {
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

        try GitHubHTTPClient.validate(response)

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
    }

    static func fetchLanguages(urlString: String, token: String?) async throws -> [Language] {
        let request = try GitHubHTTPClient.makeRequest(urlString: urlString, token: token)
        let data = try await GitHubHTTPClient.data(for: request)

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
    }

    static func fetchUserRepos(username: String) async throws -> [Repo] {
        let request = try GitHubHTTPClient.makeRequest(
            urlString: "https://api.github.com/users/\(username)/repos?per_page=100&sort=updated"
        )
        let data = try await GitHubHTTPClient.data(for: request)

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
    }
}
