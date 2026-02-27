//
//  AuthManager.swift
//  GitSwipe
//
//  Created by Osman Kahraman on 2026-02-26.
//

import SwiftUI

class AuthManager: ObservableObject {
    @Published var isLoggedIn: Bool = false
    @Published var username: String = ""
    @Published var avatarURL: String?
    @Published var publicRepos: Int = 0
    @Published var followers: Int = 0
    @Published var following: Int = 0
    @Published var accessToken: String?
    @Published var starredRepos: [Repo] = []

    func login(username: String) {
        self.username = username
        self.isLoggedIn = true
    }

    func logout() {
        self.username = ""
        self.avatarURL = nil
        self.publicRepos = 0
        self.followers = 0
        self.following = 0
        self.accessToken = nil
        self.isLoggedIn = false
    }

    func fetchGitHubUser() {
        guard let token = accessToken,
              let url = URL(string: "https://api.github.com/user") else { return }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else { return }

            DispatchQueue.main.async {
                self.username = json["login"] as? String ?? ""
                self.avatarURL = json["avatar_url"] as? String
                self.publicRepos = json["public_repos"] as? Int ?? 0
                self.followers = json["followers"] as? Int ?? 0
                self.following = json["following"] as? Int ?? 0
                self.isLoggedIn = true
                self.fetchStarredRepositories()
            }
        }.resume()
    }
    
    func fetchStarredRepositories() {
        guard let token = accessToken,
              let url = URL(string: "https://api.github.com/user/starred?per_page=5") else { return }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data,
                  let jsonArray = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
                print("Failed to parse starred repos")
                return
            }

            let repos: [Repo] = jsonArray.compactMap { item -> Repo? in
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
                    languages: []
                )
            }

            DispatchQueue.main.async {
                self.starredRepos = repos
            }
        }.resume()
    }
}
