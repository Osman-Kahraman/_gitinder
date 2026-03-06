//
//  AuthManager.swift
//  _gitinder
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
    @Published var localStarredRepos: [Repo] = []
    @Published var pendingStars: [(owner: String, repo: String)] = []
    @Published var pendingUnstars: [(owner: String, repo: String)] = []
    @Published var preferences: UserPreferences?
    @Published var needsOnboarding: Bool = false
    @Published var starLimit: Int = 100
    @Published var blacklistedRepos: Set<String> = []
    private let blacklistKey = "repo_blacklist"

    private let tokenKey = "github_access_token"

    init() {
        loadPreferences()
        loadStarLimit()
        loadBlacklist()

        if let savedToken = KeychainManager.shared.read(key: tokenKey) {
            self.accessToken = savedToken
            self.isLoggedIn = true

            // Only trigger onboarding if user is logged in AND has no preferences
            if self.isLoggedIn && self.preferences == nil {
                self.needsOnboarding = true
            }

            fetchGitHubUser()
        }
    }

    func logout() {
        KeychainManager.shared.delete(key: tokenKey)

        self.username = ""
        self.avatarURL = nil
        self.publicRepos = 0
        self.followers = 0
        self.following = 0
        self.accessToken = nil
        self.preferences = nil
        self.isLoggedIn = false
        self.needsOnboarding = false
    }
    
    func savePreferences(_ preferences: UserPreferences) {
        self.preferences = preferences
        self.needsOnboarding = false
        if let data = try? JSONEncoder().encode(preferences) {
            UserDefaults.standard.set(data, forKey: "user_preferences")
        }
    }

    func loadPreferences() {
        if let data = UserDefaults.standard.data(forKey: "user_preferences"),
           let prefs = try? JSONDecoder().decode(UserPreferences.self, from: data) {
            self.preferences = prefs
        }
    }

    func saveStarLimit(_ limit: Int) {
        self.starLimit = limit
        UserDefaults.standard.set(limit, forKey: "user_star_limit")
    }

    func loadStarLimit() {
        if let saved = UserDefaults.standard.value(forKey: "user_star_limit") as? Int {
            self.starLimit = saved
        }
    }

    func addRepoToBlacklist(owner: String, repo: String) {
        let key = "\(owner)/\(repo)"
        blacklistedRepos.insert(key)
        saveBlacklist()
    }

    func isRepoBlacklisted(owner: String, repo: String) -> Bool {
        let key = "\(owner)/\(repo)"
        return blacklistedRepos.contains(key)
    }

    private func saveBlacklist() {
        let array = Array(blacklistedRepos)
        UserDefaults.standard.set(array, forKey: blacklistKey)
    }

    private func loadBlacklist() {
        if let saved = UserDefaults.standard.array(forKey: blacklistKey) as? [String] {
            blacklistedRepos = Set(saved)
        }
    }

    func startOAuthLogin() {
        guard let clientID = Bundle.main.object(forInfoDictionaryKey: "GITHUB_CLIENT_ID") as? String else {
            print("Missing GITHUB_CLIENT_ID in Info.plist")
            return
        }
        let scope = "read:user user:email public_repo"
        let redirectURI = "gitinder://callback"

        let authURLString = "https://github.com/login/oauth/authorize?client_id=\(clientID)&scope=\(scope)&redirect_uri=\(redirectURI)"

        if let url = URL(string: authURLString) {
            UIApplication.shared.open(url)
        }
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

                if self.preferences == nil {
                    self.needsOnboarding = true
                }

                self.fetchStarredRepositories()
            }
        }.resume()
    }
    
    func fetchStarredRepositories() {
        guard let token = accessToken,
              let url = URL(string: "https://api.github.com/user/starred?per_page=25") else { return }

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
                    languages: [],
                    owner: (item["owner"] as? [String: Any])?["login"] as? String ?? ""
                )
            }

            DispatchQueue.main.async {
                self.starredRepos = repos
                if self.localStarredRepos.isEmpty {
                    self.localStarredRepos = self.starredRepos
                }
            }
        }.resume()
    }
    
    func starRepository(owner: String, repo: String) {
        guard let token = accessToken else { return }

        let urlString = "https://api.github.com/user/starred/\(owner)/\(repo)"
        
        guard let url = URL(string: urlString) else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"

        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        request.setValue("0", forHTTPHeaderField: "Content-Length")

        // GitHub expects an empty body for PUT star requests
        request.httpBody = Data()

        URLSession.shared.dataTask(with: request) { data, response, error in

            if let error = error {
                print("Star error:", error)
                return
            }

            if let http = response as? HTTPURLResponse {
                print("Star status:", http.statusCode)
            }

            if let data = data,
               let body = String(data: data, encoding: .utf8),
               !body.isEmpty {
                print("GitHub response:", body)
            }

        }.resume()
    }
    
    func unstarRepository(owner: String, repo: String) {
        guard let token = accessToken else { return }

        let urlString = "https://api.github.com/user/starred/\(owner)/\(repo)"
        guard let url = URL(string: urlString) else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"

        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")

        URLSession.shared.dataTask(with: request) { data, response, error in

            if let error = error {
                print("Unstar error:", error)
                return
            }

            if let http = response as? HTTPURLResponse {
                print("Unstar status:", http.statusCode)
            }

        }.resume()
    }
    
    func addLocalStar(repo: Repo) {
        if !localStarredRepos.contains(where: { $0.owner == repo.owner && $0.name == repo.name }) {
            localStarredRepos.insert(repo, at: 0)
            pendingStars.append((owner: repo.owner, repo: repo.name))
        }
    }

    func removeLocalStar(owner: String, repo: String) {
        if let index = localStarredRepos.firstIndex(where: { $0.owner == owner && $0.name == repo }) {
            localStarredRepos.remove(at: index)
            pendingUnstars.append((owner: owner, repo: repo))
        }
    }

    func syncStarChanges() {
        for item in pendingStars {
            starRepository(owner: item.owner, repo: item.repo)
        }

        for item in pendingUnstars {
            unstarRepository(owner: item.owner, repo: item.repo)
        }

        pendingStars.removeAll()
        pendingUnstars.removeAll()
    }
}
