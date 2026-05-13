//
//  HomeView.swift
//  _gitinder
//
//  Created by Osman Kahraman on 2026-02-25.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var auth: AuthManager
    @State private var repos: [Repo] = []
    @State private var allRepos: [Repo] = []

    @State private var currentIndex = 0
    @State private var isFetchingRepos = false
    @State private var fetchTask: Task<Void, Never>?
    @State private var feedStatusMessage: String?
    

    var body: some View {
        HomeContentView(
            repos: $repos,
            currentIndex: $currentIndex,
            isLoadingFeed: $isFetchingRepos,
            feedStatusMessage: $feedStatusMessage,
            fetchTrendingRepositories: fetchTrendingRepositories
        )
        .environmentObject(auth)
    }

    private func fetchTrendingRepositories(resetDeck: Bool) {
        fetchTask?.cancel()
        fetchTask = Task {
            await loadTrendingRepositories(resetDeck: resetDeck)
        }
    }

    @MainActor
    private func loadTrendingRepositories(resetDeck: Bool) async {
        isFetchingRepos = true
        defer {
            if !Task.isCancelled {
                isFetchingRepos = false
            }
        }

        let preferences = auth.preferences

        if resetDeck {
            allRepos = []
            repos = []
            currentIndex = 0
        }

        feedStatusMessage = "Finding great repositories for you..."

        if preferences.starLimit == -1 {
            do {
                let fetchedRepos = try await GitHubService.fetchUserRepos(username: "Osman-Kahraman")
                self.allRepos = fetchedRepos
                self.repos = fetchedRepos
                self.currentIndex = 0
                self.feedStatusMessage = nil
                auth.errorMessage = nil
            } catch {
                if Task.isCancelled { return }
                showFeedError(error)
            }
            return
        }
        
        guard !preferences.selectedLanguages.isEmpty else {
            do {
                let query = buildRepoQuery(language: nil, preferences: preferences)
                let newRepos = try await fetchAndAppendRepos(query: query)
                await fetchLanguages(for: Array(newRepos.prefix(5)))
            } catch {
                if Task.isCancelled { return }
                showFeedError(error)
            }
            return
        }

        // Limit to first 5 languages to avoid GitHub boolean operator limit
        let languages = Array(preferences.selectedLanguages.prefix(5))

        do {
            for language in languages {
                if Task.isCancelled { return }

                let query = buildRepoQuery(language: language, preferences: preferences)
                let newRepos = try await fetchAndAppendRepos(query: query)
                await fetchLanguages(for: Array(newRepos.prefix(5)))
                try await Task.sleep(nanoseconds: 500_000_000)
            }
        } catch {
            if Task.isCancelled { return }
            showFeedError(error)
        }
    }

    @MainActor
    private func fetchAndAppendRepos(query: String) async throws -> [Repo] {
        let newRepos = try await GitHubService.fetchRepos(
            query: query,
            token: auth.accessToken,
            existing: self.allRepos,
            blacklistCheck: { repo in
                auth.isRepoBlacklisted(owner: repo.owner, repo: repo.name)
            },
            onRateLimited: {
                await MainActor.run {
                    feedStatusMessage = "GitHub rate limit reached. Retrying in 30 seconds..."
                }
            }
        )

        appendReposToDeck(newRepos)
        feedStatusMessage = nil
        auth.errorMessage = nil

        if currentIndex >= repos.count {
            currentIndex = 0
        }

        return newRepos
    }

    @MainActor
    private func appendReposToDeck(_ newRepos: [Repo]) {
        let existingIDs = Set(allRepos.map { "\($0.owner)/\($0.name)" })
        let uniqueRepos = newRepos.filter { repo in
            !existingIDs.contains("\(repo.owner)/\(repo.name)")
        }
        let shuffledNewRepos = uniqueRepos.shuffled()

        allRepos.append(contentsOf: shuffledNewRepos)
        repos.append(contentsOf: shuffledNewRepos)
    }

    private func buildRepoQuery(language: String?, preferences: UserPreferences) -> String {
        var query = language.map { "language:\($0) " } ?? ""
        query += "stars:<\(preferences.starLimit)"

        if preferences.recentlyUpdatedDays > 0 {
            let date = Calendar.current.date(
                byAdding: .day,
                value: -preferences.recentlyUpdatedDays,
                to: Date()
            ) ?? Date()

            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            let dateString = formatter.string(from: date)

            query += " pushed:>\(dateString)"
        }

        return query
    }

    @MainActor
    private func fetchLanguages(for repos: [Repo]) async {
        for repo in repos {
            if Task.isCancelled { return }

            do {
                let languages = try await GitHubService.fetchLanguages(
                    urlString: repo.languagesURL,
                    token: auth.accessToken
                )

                if let index = self.allRepos.firstIndex(where: { $0.id == repo.id }) {
                    self.allRepos[index].languages = languages
                }

                if let index = self.repos.firstIndex(where: { $0.id == repo.id }) {
                    self.repos[index].languages = languages
                }
            } catch {
                if Task.isCancelled { return }
                showFeedError(error)
            }
        }
    }

    private func showFeedError(_ error: Error) {
        let message: String

        if case GitHubClientError.rateLimited = error {
            feedStatusMessage = "GitHub rate limit reached. Please try again later."
            return
        }

        if let localizedError = error as? LocalizedError,
           let description = localizedError.errorDescription {
            message = "Couldn't load feed: \(description)"
        } else {
            message = "Couldn't load feed. Please try again."
        }

        feedStatusMessage = message
        auth.errorMessage = message
    }
}

#Preview {
    HomeView()
        .environmentObject(AuthManager())
}
