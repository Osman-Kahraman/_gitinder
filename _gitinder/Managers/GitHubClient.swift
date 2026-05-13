//
//  GitHubClient.swift
//  _gitinder
//
//  Created by Osman Kahraman on 2026-03-09.
//

import Foundation

final class GitHubClient {
    func fetchCurrentUser(token: String) async throws -> UserProfile {
        let request = try GitHubHTTPClient.makeRequest(
            urlString: "https://api.github.com/user",
            token: token
        )
        let data = try await GitHubHTTPClient.data(for: request)

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
        let request = try GitHubHTTPClient.makeRequest(
            urlString: "https://api.github.com/user/starred?per_page=25",
            token: token
        )
        let data = try await GitHubHTTPClient.data(for: request)

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
        let request = try GitHubHTTPClient.makeRequest(
            urlString: "https://api.github.com/user/starred/\(owner)/\(repo)",
            method: "PUT",
            token: token,
            body: Data(),
            additionalHeaders: ["Content-Length": "0"]
        )

        _ = try await GitHubHTTPClient.data(for: request)
        return true
    }

    func unstarRepository(owner: String, repo: String, token: String) async throws -> Bool {
        let request = try GitHubHTTPClient.makeRequest(
            urlString: "https://api.github.com/user/starred/\(owner)/\(repo)",
            method: "DELETE",
            token: token
        )

        _ = try await GitHubHTTPClient.data(for: request)
        return true
    }
}
