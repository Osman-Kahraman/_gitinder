//
//  GitHubService.swift
//  _gitinder
//
//  Created by Osman Kahraman on 2026-05-05.
//

import Foundation
import SwiftUI

class GitHubService {
    static func fetchRepos(
        query: String,
        token: String?,
        existing: [Repo],
        blacklistCheck: @escaping (Repo) -> Bool,
        completion: @escaping ([Repo]) -> Void
    ) {

        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""

        var allFetched: [Repo] = []
        let group = DispatchGroup()

        for page in 1...3 {
            guard let url = URL(string:
                "https://api.github.com/search/repositories?q=\(encodedQuery)&sort=stars&order=desc&per_page=100&page=\(page)"
            ) else { continue }

            group.enter()

            var request = URLRequest(url: url)
            request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")

            if let token = token {
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }

            URLSession.shared.dataTask(with: request) { data, response, _ in
                defer { group.leave() }

                guard let data = data else { return }

                if let response = response as? HTTPURLResponse, response.statusCode == 403 {
                    print("⚠️ Rate limit hit")
                    return
                }

                guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                      let items = json["items"] as? [[String: Any]] else { return }

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

                allFetched.append(contentsOf: repos)

            }.resume()
        }

        group.notify(queue: .main) {

            let existingIDs = Set(existing.map { "\($0.owner)/\($0.name)" })

            let unique = allFetched.filter {
                !existingIDs.contains("\($0.owner)/\($0.name)")
            }

            let filtered = unique.filter { repo in
                !blacklistCheck(repo)
            }

            completion(filtered)
        }
    }
    
    static func fetchLanguages(
        urlString: String,
        token: String?,
        completion: @escaping ([Language]) -> Void
    ) {
        guard let url = URL(string: urlString) else { return }

        var request = URLRequest(url: url)

        if let token = token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        URLSession.shared.dataTask(with: request) { data, _, _ in
            guard let data = data,
                  let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Int] else {
                completion([])
                return
            }

            let total = dict.values.reduce(0, +)

            let mapped = dict.map { key, value in
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

            DispatchQueue.main.async {
                completion(mapped)
            }
        }.resume()
    }
    
    static func fetchUserRepos(
        username: String,
        completion: @escaping ([Repo]) -> Void
    ) {
        guard let url = URL(string:
            "https://api.github.com/users/\(username)/repos?per_page=100&sort=updated"
        ) else { return }

        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
                return
            }

            let repos = json.compactMap { item -> Repo? in
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

            DispatchQueue.main.async {
                completion(repos)
            }
        }.resume()
    }
}
