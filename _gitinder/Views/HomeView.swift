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
    

    var body: some View {
        switch auth.phase {
            case .unauthenticated:
                LoginView()
                    .environmentObject(auth)

            case .loading:
                LoadingView()
                    .onAppear {}

            case .error(let message):
                VStack(spacing: 16) {
                    Text(message)
                        .foregroundColor(.white)
                    Button("Try Again") {
                        Task { await auth.fetchGitHubUser() }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.black.ignoresSafeArea())

            case .ready:
                HomeContentView(
                    repos: $repos,
                    currentIndex: $currentIndex,
                    fetchTrendingRepositories: fetchTrendingRepositories
                )
                .environmentObject(auth)
        }
    }

    private func fetchTrendingRepositories() {
        let preferences = auth.preferences

        if preferences.starLimit == -1 {
            GitHubService.fetchUserRepos(username: "Osman-Kahraman") { repos in
                self.allRepos = repos
                self.repos = repos
                self.currentIndex = 0
            }
            return
        }
        
        guard !preferences.selectedLanguages.isEmpty else {
            var query = "stars:<\(preferences.starLimit)"

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

            GitHubService.fetchRepos(
                query: query,
                token: auth.accessToken,
                existing: self.allRepos,
                blacklistCheck: { repo in
                    auth.isRepoBlacklisted(owner: repo.owner, repo: repo.name)
                }
            ) { newRepos in
                self.allRepos.append(contentsOf: newRepos)
                self.repos = self.allRepos.shuffled()

                if self.currentIndex >= self.repos.count {
                    self.currentIndex = 0
                }

                for repo in newRepos.prefix(5) {
                    GitHubService.fetchLanguages(
                        urlString: repo.languagesURL,
                        token: auth.accessToken
                    ) { languages in
                        if let index = self.allRepos.firstIndex(where: { $0.id == repo.id }) {
                            self.allRepos[index].languages = languages
                        }
                    }
                }
            }
            return
        }

        // Limit to first 5 languages to avoid GitHub boolean operator limit
        let languages = Array(preferences.selectedLanguages.prefix(5))

        self.allRepos = []
        self.repos = []
        self.currentIndex = 0

        DispatchQueue.global().async {
            for (_, language) in languages.enumerated() {
                var query = "language:\(language) stars:<\(preferences.starLimit)"

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

                DispatchQueue.main.async {
                    GitHubService.fetchRepos(
                        query: query,
                        token: auth.accessToken,
                        existing: self.allRepos,
                        blacklistCheck: { repo in
                            auth.isRepoBlacklisted(owner: repo.owner, repo: repo.name)
                        }
                    ) { newRepos in
                        self.allRepos.append(contentsOf: newRepos)
                        self.repos = self.allRepos.shuffled()

                        if self.currentIndex >= self.repos.count {
                            self.currentIndex = 0
                        }

                        for repo in newRepos.prefix(5) {
                            GitHubService.fetchLanguages(
                                urlString: repo.languagesURL,
                                token: auth.accessToken
                            ) { languages in
                                if let index = self.allRepos.firstIndex(where: { $0.id == repo.id }) {
                                    self.allRepos[index].languages = languages
                                }
                            }
                        }
                    }
                }

                // Throttle requests (0.5s delay)
                Thread.sleep(forTimeInterval: 0.5)
            }
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(AuthManager())
}
