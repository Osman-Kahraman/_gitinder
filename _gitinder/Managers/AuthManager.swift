//
//  AuthManager.swift
//  _gitinder
//
//  Created by Osman Kahraman on 2026-02-26.
//

import SwiftUI

@MainActor
class AuthManager: ObservableObject {
    @Published var profile = UserProfile()
    @Published var accessToken: String?
    @Published var starState = StarState()
    @Published var preferences = UserPreferences()
    @Published var blacklistedRepos: Set<String> = []
    @Published private(set) var isSyncingStars = false
    private let blacklistKey = "repo_blacklist"

    private let tokenKey = "github_access_token"
    private let preferencesKey = "user_preferences"

    var isLoggedIn: Bool {
        accessToken != nil
    }

    var needsOnboarding: Bool {
        isLoggedIn && preferences.selectedLanguages.isEmpty
    }

    init() {
        loadPreferences()
        loadBlacklist()

        if let savedToken = KeychainManager.shared.read(key: tokenKey) {
            self.accessToken = savedToken
            Task {
                await fetchGitHubUser()
            }
        }
    }
    
    func logout() {
        KeychainManager.shared.delete(key: tokenKey)
        clearPreferences()

        profile = UserProfile()
        self.accessToken = nil
        self.starState = StarState()
    }
    
    func savePreferences(_ preferences: UserPreferences) {
        self.preferences = preferences
        if let data = try? JSONEncoder().encode(preferences) {
            UserDefaults.standard.set(data, forKey: preferencesKey)
        }
    }

    func loadPreferences() {
        if let data = UserDefaults.standard.data(forKey: preferencesKey),
           let prefs = try? JSONDecoder().decode(UserPreferences.self, from: data) {
            self.preferences = prefs
        }
    }

    func saveStarLimit(_ limit: Int) {
        var updatedPreferences = preferences
        updatedPreferences.starLimit = limit
        savePreferences(updatedPreferences)
    }

    func saveRecentlyUpdatedDays(_ days: Int) {
        var updatedPreferences = preferences
        updatedPreferences.recentlyUpdatedDays = days
        savePreferences(updatedPreferences)
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

    private func clearPreferences() {
        preferences = UserPreferences()
        UserDefaults.standard.removeObject(forKey: preferencesKey)
    }

    func getOAuthURL() -> URL? {
        guard let clientID = Bundle.main.object(forInfoDictionaryKey: "CLIENT_ID") as? String else {
            print("Missing CLIENT_ID in Info.plist")
            return nil
        }
        let scope = "read:user user:email public_repo"
        let redirectURI = "gitinder://callback"

        let authURLString = "https://github.com/login/oauth/authorize?client_id=\(clientID)&scope=\(scope)&redirect_uri=\(redirectURI)"

        return URL(string: authURLString)
    }

    func fetchGitHubUser() async {
        guard let token = accessToken,
              let url = URL(string: "https://api.github.com/user") else { return }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")

        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else { return }

            self.profile.username = json["login"] as? String ?? ""
            self.profile.avatarURL = json["avatar_url"] as? String
            self.profile.publicRepos = json["public_repos"] as? Int ?? 0
            self.profile.followers = json["followers"] as? Int ?? 0
            self.profile.following = json["following"] as? Int ?? 0

            await fetchStarredRepositories()
        } catch {
            print("Fetch user error:", error)
        }
    }
    
    func fetchStarredRepositories() async {
        guard let token = accessToken,
              let url = URL(string: "https://api.github.com/user/starred?per_page=25") else { return }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")

        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            guard let jsonArray = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
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

            self.starState.starredRepos = repos
            if self.starState.localStarredRepos.isEmpty {
                self.starState.localStarredRepos = self.starState.starredRepos
            }
        } catch {
            print("Fetch starred repos error:", error)
        }
    }
    
    func starRepository(owner: String, repo: String) async -> Bool {
        guard let token = accessToken else { return false }

        let urlString = "https://api.github.com/user/starred/\(owner)/\(repo)"
        
        guard let url = URL(string: urlString) else { return false }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"

        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        request.setValue("0", forHTTPHeaderField: "Content-Length")

        // GitHub expects an empty body for PUT star requests
        request.httpBody = Data()

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            if let http = response as? HTTPURLResponse {
                print("Star status:", http.statusCode)
                let isSuccess = (200...299).contains(http.statusCode)

                if let body = String(data: data, encoding: .utf8), !body.isEmpty {
                    print("GitHub response:", body)
                }

                return isSuccess
            }

            return false
        } catch {
            print("Star error:", error)
            return false
        }
    }
    
    func unstarRepository(owner: String, repo: String) async -> Bool {
        guard let token = accessToken else { return false }

        let urlString = "https://api.github.com/user/starred/\(owner)/\(repo)"
        guard let url = URL(string: urlString) else { return false }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"

        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")

        do {
            let (_, response) = try await URLSession.shared.data(for: request)

            if let http = response as? HTTPURLResponse {
                print("Unstar status:", http.statusCode)
                return (200...299).contains(http.statusCode)
            }

            return false
        } catch {
            print("Unstar error:", error)
            return false
        }
    }
    
    func addLocalStar(repo: Repo) {
        starState.pendingUnstars.removeAll { pendingItem in
            pendingItem.owner == repo.owner && pendingItem.name == repo.name
        }

        if !starState.localStarredRepos.contains(where: { $0.owner == repo.owner && $0.name == repo.name }) {
            starState.localStarredRepos.insert(repo, at: 0)
        }

        if !starState.pendingStars.contains(where: { pendingItem in
            pendingItem.owner == repo.owner && pendingItem.name == repo.name
        }) {
            starState.pendingStars.append(RepoReference(owner: repo.owner, name: repo.name))
        }
    }

    func removeLocalStar(owner: String, repo: String) {
        starState.pendingStars.removeAll { pendingItem in
            pendingItem.owner == owner && pendingItem.name == repo
        }

        if let index = starState.localStarredRepos.firstIndex(where: { $0.owner == owner && $0.name == repo }) {
            starState.localStarredRepos.remove(at: index)
        }

        if !starState.pendingUnstars.contains(where: { pendingItem in
            pendingItem.owner == owner && pendingItem.name == repo
        }) {
            starState.pendingUnstars.append(RepoReference(owner: owner, name: repo))
        }
    }

    func syncStarChanges() {
        guard !isSyncingStars else { return }
        Task {
            await performStarSync()
        }
    }

    private func performStarSync() async {
        let pendingStarsSnapshot = starState.pendingStars
        let pendingUnstarsSnapshot = starState.pendingUnstars
        let totalOperations = pendingStarsSnapshot.count + pendingUnstarsSnapshot.count

        guard totalOperations > 0 else { return }

        isSyncingStars = true
        defer { isSyncingStars = false }

        for item in pendingStarsSnapshot {
            let success = await starRepository(owner: item.owner, repo: item.name)
            if success {
                starState.pendingStars.removeAll { pendingItem in
                    pendingItem == item
                }
            }
        }

        for item in pendingUnstarsSnapshot {
            let success = await unstarRepository(owner: item.owner, repo: item.name)
            if success {
                starState.pendingUnstars.removeAll { pendingItem in
                    pendingItem == item
                }
            }
        }
    }
}
