//
//  HomeView.swift
//  _gitinder
//
//  Created by Osman Kahraman on 2026-02-25.
//

import SwiftUI

struct Language {
    let name: String
    let percentage: Double
    let color: Color
}

struct Repo {
    let name: String
    let description: String
    let star: Int
    let fork: Int
    let issues: Int
    let lastUpdate: String
    let languagesURL: String
    var languages: [Language]
}

struct HomeView: View {
    @EnvironmentObject var auth: AuthManager
    @State private var repos: [Repo] = []
    @State private var allRepos: [Repo] = []

    @State private var currentIndex = 0
    @State private var dragOffset: CGFloat = 0
    @State private var lastSwipeDirection: CGFloat = 0

    var body: some View {
        ZStack {
            Color.black
                .overlay(
                    LinearGradient(
                        colors: [.red.opacity(0.1), .clear, .clear, .clear, .clear, .clear, .green.opacity(0.1)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .overlay(
                    Color.green.opacity(dragOffset > 0 ? min(Double(dragOffset / 150), 0.4) : 0)
                )
                .overlay(
                    Color.red.opacity(dragOffset < 0 ? min(Double(-dragOffset / 150), 0.4) : 0)
                )
                .ignoresSafeArea()

            VStack {
                Text("_gitinder")
                    .foregroundColor(.white)
                    .font(.custom("Doto-Black_ExtraBold", size: 28))

                Spacer()

                if currentIndex < repos.count {
                    ZStack {
                        SwipeCard(
                            repo: repos[currentIndex],
                            onSwipeLeft: {
                                lastSwipeDirection = -1
                                nextCard()
                            },
                            onSwipeRight: {
                                lastSwipeDirection = 1
                                nextCard()
                            },
                            onDragChanged: { value in
                                dragOffset = value
                            },
                            onDragEnded: {
                                withAnimation(.easeOut(duration: 0.6)) {
                                    dragOffset = 0
                                }
                            }
                        )
                        .id(currentIndex)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: lastSwipeDirection > 0 ? .trailing : .leading)
                                .combined(with: .opacity)
                        ))
                    }
                } else {
                    Text("Woah! You reached your limit today, come tomorrow...")
                        .foregroundColor(.white)
                        .font(.custom("Doto-Black_Bold", size: 24))
                }

                Spacer()
            }
        }
        .animation(.easeOut(duration: 0.6), value: dragOffset)
        .animation(.spring(), value: currentIndex)
        .onAppear {
            fetchTrendingRepositories()
        }
    }

    func nextCard() {
        withAnimation(.spring()) {
            currentIndex += 1
        }
    }

    func filterReposByPreferences(_ repos: [Repo]) -> [Repo] {
        guard let prefs = auth.preferences else { return repos }

        return repos.filter { repo in
            let totalMatchPercentage = repo.languages
                .filter { prefs.selectedLanguages.contains($0.name) }
                .reduce(0) { $0 + $1.percentage }

            return totalMatchPercentage >= 50
        }
    }

    private func fetchTrendingRepositories() {
        guard let url = URL(string: "https://api.github.com/search/repositories?q=stars:>1000&sort=stars&order=desc&per_page=20") else { return }

        var request = URLRequest(url: url)
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")

        URLSession.shared.dataTask(with: request) { data, _, _ in
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let items = json["items"] as? [[String: Any]] else {
                return
            }

            let fetchedRepos: [Repo] = items.compactMap { item in
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
                    lastUpdate: item["updated_at"] as? String ?? "",
                    languagesURL: item["languages_url"] as? String ?? "",
                    languages: []
                )
            }

            DispatchQueue.main.async {
                self.allRepos = fetchedRepos
                self.repos = fetchedRepos
                self.currentIndex = 0

                for index in self.allRepos.indices {
                    fetchLanguages(for: self.allRepos[index], at: index)
                }
            }
        }.resume()
    }

    private func fetchLanguages(for repo: Repo, at index: Int) {
        guard let url = URL(string: repo.languagesURL) else { return }

        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data,
                  let languageDict = try? JSONSerialization.jsonObject(with: data) as? [String: Int] else {
                return
            }

            let total = languageDict.values.reduce(0, +)

            let mappedLanguages: [Language] = languageDict.map { key, value in
                let percentage = total > 0 ? (Double(value) / Double(total)) * 100 : 0
                let randomColor = Color(
                    hue: Double.random(in: 0...1),
                    saturation: 0.7,
                    brightness: 0.9
                )
                return Language(name: key, percentage: percentage, color: randomColor)
            }

            DispatchQueue.main.async {
                if index < self.allRepos.count {
                    self.allRepos[index].languages = mappedLanguages
                }

                let filtered = filterReposByPreferences(self.allRepos)
                self.repos = filtered

                if self.currentIndex >= self.repos.count {
                    self.currentIndex = 0
                }
            }
        }.resume()
    }
}

#Preview {
    HomeView()
        .environmentObject(AuthManager())
}
