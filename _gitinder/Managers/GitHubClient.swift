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
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            try validate(response)

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
        } catch let error as GitHubClientError {
            throw error
        } catch {
            throw GitHubClientError.network(error)
        }
    }

    func fetchStarredRepositories(token: String) async throws -> [Repo] {
        guard let url = URL(string: "https://api.github.com/user/starred?per_page=25") else {
            throw GitHubClientError.invalidURL
        }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            try validate(response)

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
        } catch let error as GitHubClientError {
            throw error
        } catch {
            throw GitHubClientError.network(error)
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

        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            try validate(response)
            return true
        } catch let error as GitHubClientError {
            throw error
        } catch {
            throw GitHubClientError.network(error)
        }
    }

    func unstarRepository(owner: String, repo: String, token: String) async throws -> Bool {
        guard let url = URL(string: "https://api.github.com/user/starred/\(owner)/\(repo)") else {
            throw GitHubClientError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")

        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            try validate(response)
            return true
        } catch let error as GitHubClientError {
            throw error
        } catch {
            throw GitHubClientError.network(error)
        }
    }

    private func validate(_ response: URLResponse) throws {
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
}

enum GitHubClientError: LocalizedError {
    case invalidURL
    case invalidResponse
    case unauthorized
    case rateLimited
    case serverError(Int)
    case network(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            "Invalid GitHub URL."
        case .invalidResponse:
            "GitHub returned an invalid response."
        case .unauthorized:
            "GitHub authorization failed. Please log in again."
        case .rateLimited:
            "GitHub rate limit reached. It will try again 30 seconds later."
        case .serverError(let code):
            "GitHub server error: \(code)."
        case .network:
            "Network connection failed."
        }
    }
}
