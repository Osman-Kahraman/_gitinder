//
//  AuthController.swift
//  _gitinder
//
//  Created by Osman Kahraman on 2026-02-26.
//

import SwiftUI

enum AuthPhase: Equatable {
    case unauthenticated
    case loading
    case ready
    case error(String)
}

@MainActor
class AuthController: ObservableObject {
    @Published var profile = UserProfile()
    @Published var accessToken: String?
    @Published var starState = StarState()
    @Published var preferences = UserPreferences()
    @Published var blacklistedRepos: Set<String> = []
    @Published private(set) var isSyncingStars = false
    @Published var phase: AuthPhase = .unauthenticated
    
    @Published var errorMessage: String?

    private let credentialsStore = CredentialsStore()
    private let gitHubAPIClient = GitHubAPIClient()
    private let preferencesStore = PreferencesStore()

    var isLoggedIn: Bool {
        if case .ready = phase { return true }
        
        return false
    }

    var needsOnboarding: Bool {
        isLoggedIn && preferences.selectedLanguages.isEmpty
    }

    init() {
        preferences = preferencesStore.loadPreferences()
        blacklistedRepos = preferencesStore.loadBlacklist()

        if let savedToken = credentialsStore.loadAccessToken() {
            self.accessToken = savedToken
            self.phase = .loading
            Task {
                await fetchGitHubUser()
            }
        } else {
            self.phase = .unauthenticated
        }
    }
    
    func logout() {
        credentialsStore.clearAccessToken()
        clearPreferences()

        profile = UserProfile()
        self.accessToken = nil
        self.starState = StarState()
        self.errorMessage = nil
        self.phase = .unauthenticated
    }
    
    func savePreferences(_ preferences: UserPreferences) {
        self.preferences = preferences
        preferencesStore.savePreferences(preferences)
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
        preferencesStore.saveBlacklist(blacklistedRepos)
    }

    func isRepoBlacklisted(owner: String, repo: String) -> Bool {
        let key = "\(owner)/\(repo)"
        return blacklistedRepos.contains(key)
    }

    private func clearPreferences() {
        preferences = UserPreferences()
        preferencesStore.clearPreferences()
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
        guard let token = accessToken else {
            self.phase = .unauthenticated
            return
        }

        self.phase = .loading
        self.errorMessage = nil

        do {
            self.profile = try await gitHubAPIClient.fetchCurrentUser(token: token)
            await fetchStarredRepositories()
            self.phase = .ready
        } catch {
            if isUnauthorized(error) {
                logout()
                self.phase = .unauthenticated
            } else {
                self.phase = .error(userFacingMessage(prefix: "Couldn't get user infos", error: error))
            }
        }
    }
    
    private func isUnauthorized(_ error: Error) -> Bool {
        if case GitHubClientError.unauthorized = error {
            return true
        }

        if case let GitHubClientError.network(underlyingError) = error {
            return isUnauthorized(underlyingError)
        }

        return false
    }
    
    func fetchStarredRepositories() async {
        guard let token = accessToken else { return }

        do {
            let repos = try await gitHubAPIClient.fetchStarredRepositories(token: token)
            self.starState.starredRepos = repos
            self.errorMessage = nil
            if self.starState.localStarredRepos.isEmpty {
                self.starState.localStarredRepos = self.starState.starredRepos
            }
        } catch {
            handleRecoverableGitHubError(error, fallbackMessage: "Couldn't refresh starred repositories")
        }
    }
    
    func starRepository(owner: String, repo: String) async -> Bool {
        guard let token = accessToken else { return false }

        do {
            let success = try await gitHubAPIClient.starRepository(owner: owner, repo: repo, token: token)
            self.errorMessage = nil
            return success
        } catch {
            handleRecoverableGitHubError(error, fallbackMessage: "Couldn't star \(owner)/\(repo)")
            return false
        }
    }
    
    func unstarRepository(owner: String, repo: String) async -> Bool {
        guard let token = accessToken else { return false }

        do {
            let success = try await gitHubAPIClient.unstarRepository(owner: owner, repo: repo, token: token)
            self.errorMessage = nil
            return success
        } catch {
            handleRecoverableGitHubError(error, fallbackMessage: "Couldn't unstar \(owner)/\(repo)")
            return false
        }
    }

    private func handleRecoverableGitHubError(_ error: Error, fallbackMessage: String) {
        if isUnauthorized(error) {
            logout()
        } else {
            self.errorMessage = userFacingMessage(prefix: fallbackMessage, error: error)
        }
    }

    private func userFacingMessage(prefix: String, error: Error) -> String {
        if let localizedError = error as? LocalizedError,
           let description = localizedError.errorDescription {
            return "\(prefix): \(description)"
        }

        return "\(prefix). Please try again."
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
