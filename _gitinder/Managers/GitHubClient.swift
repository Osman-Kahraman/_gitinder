//
//  GitHubClient.swift
//  _gitinder
//
//  Created by Osman Kahraman on 2026-03-09.
//

import Foundation

final class GitHubClient {
    func fetchCurrentUser(token: String) async throws -> UserProfile {
        guard let url = URL(string: "https://api.github.com/user") else {
            throw GitHubClientError.invalidURL
        }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")

        let (data, _) = try await URLSession.shared.data(for: request)
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw GitHubClientError.invalidResponse
        }

        return UserProfile(
            username: json["login"] as? String ?? "",
            avatarURL: json["avatar_url"] as? String,
            publicRepos: json["public_repos"] as? Int ?? 0,
            followers: json["followers"] as? Int ?? 0,
            following: json["following"] as? Int ?? 0
        )
    }

    func fetchStarredRepositories(token: String) async throws -> [Repo] {
        guard let url = URL(string: "https://api.github.com/user/starred?per_page=25") else {
            throw GitHubClientError.invalidURL
        }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")

        let (data, _) = try await URLSession.shared.data(for: request)
        guard let jsonArray = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
            throw GitHubClientError.invalidResponse
        }

        return jsonArray.compactMap { item -> Repo? in
            guard let name = item["name"] as? String,
                  let description = item["description"] as? String else {
                return nil
            }

            return Repo(
                name: name,
                description: description,
                star: item["stargazers_count"] as? Int ?? 0,
                fork: item["forks_count"] as? Int ?? 0,
                issues: item["open_issues_count"] as? Int ?? 0,
                lastUpdate: "",
                languagesURL: "",
                languages: [],
                owner: (item["owner"] as? [String: Any])?["login"] as? String ?? ""
            )
        }
    }

    func starRepository(owner: String, repo: String, token: String) async throws -> Bool {
        guard let url = URL(string: "https://api.github.com/user/starred/\(owner)/\(repo)") else {
            throw GitHubClientError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        request.setValue("0", forHTTPHeaderField: "Content-Length")
        request.httpBody = Data()

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse else {
            throw GitHubClientError.invalidResponse
        }

        print("Star status:", http.statusCode)
        if let body = String(data: data, encoding: .utf8), !body.isEmpty {
            print("GitHub response:", body)
        }

        return (200...299).contains(http.statusCode)
    }

    func unstarRepository(owner: String, repo: String, token: String) async throws -> Bool {
        guard let url = URL(string: "https://api.github.com/user/starred/\(owner)/\(repo)") else {
            throw GitHubClientError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")

        let (_, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse else {
            throw GitHubClientError.invalidResponse
        }

        print("Unstar status:", http.statusCode)
        return (200...299).contains(http.statusCode)
    }
}

enum GitHubClientError: Error {
    case invalidURL
    case invalidResponse
}
