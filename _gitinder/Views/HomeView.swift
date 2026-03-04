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

struct Repo: Identifiable {
    let id = UUID()
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
    @State private var showLanguagePreferences = false

    var body: some View {
        ZStack {
            Color.black
                .overlay(
                    LinearGradient(
                        colors: [.clear],
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
                HStack(spacing: 8) {
                    Image(systemName: "slider.horizontal.3")
                        .foregroundColor(.gray)
                    Button {
                        withAnimation(.spring()) {
                            showLanguagePreferences.toggle()
                        }
                    } label: {
                        HStack {
                            Text("Languages")
                                .foregroundColor(.white)
                                .font(.custom("Doto-Black_ExtraBold", size: 14))

                            Spacer()

                            Image(systemName: showLanguagePreferences ? "chevron.up" : "chevron.down")
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color.black)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.white.opacity(0.8), lineWidth: 1.5)
                        )
                        .cornerRadius(14)
                        .padding(.horizontal)
                    }
                }

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
                    Text(":)")
                        .foregroundColor(.white)
                        .font(.custom("Doto-Black_Bold", size: 24))
                }

                Spacer()
            }
        }
        .animation(.easeOut(duration: 0.6), value: dragOffset)
        .animation(.spring(), value: currentIndex)
        .sheet(isPresented: $showLanguagePreferences) {
            PreferencesView()
                .environmentObject(auth)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
                .presentationBackground(.black)
        }
        .onAppear {
            fetchTrendingRepositories()
        }
        .onReceive(auth.$preferences) { _ in
            // Refetch whenever preferences object changes
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
        guard let prefs = auth.preferences,
              !prefs.selectedLanguages.isEmpty else {
            fetchSingleQuery(query: "stars:<100")
            return
        }

        // Limit to first 5 languages to avoid GitHub boolean operator limit
        let languages = Array(prefs.selectedLanguages.prefix(5))

        self.allRepos = []
        self.repos = []
        self.currentIndex = 0

        for language in languages {
            let query = "language:\(language) stars:<100"
            fetchSingleQuery(query: query)
        }
    }

    private func fetchSingleQuery(query: String) {
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        guard let url = URL(string: "https://api.github.com/search/repositories?q=\(encodedQuery)&sort=stars&order=desc&per_page=50") else { return }

        var request = URLRequest(url: url)
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")

        // Authenticated request to increase rate limit
        if let token = auth.accessToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        URLSession.shared.dataTask(with: request) { data, response, _ in
            guard let data = data else {
                print("No data returned for query:", query)
                return
            }

            if let response = response as? HTTPURLResponse {
                print("Status Code for \(query):", response.statusCode)
            }

            guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                print("X JSON parse failed for query:", query)
                print(String(data: data, encoding: .utf8) ?? "No readable body")
                return
            }

            guard let items = json["items"] as? [[String: Any]] else {
                print("! No 'items' in response for query:", query)
                print(json)
                return
            }

            print("Query:", query, "| Repo Count:", items.count)

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
                let existingNames = Set(self.allRepos.map { $0.name })
                let newUnique = fetchedRepos.filter { !existingNames.contains($0.name) }

                self.allRepos.append(contentsOf: newUnique)

                // Shuffle to mix different language results
                self.allRepos.shuffle()

                self.repos = self.allRepos

                // Only reset index if this is the first load
                if self.currentIndex >= self.repos.count {
                    self.currentIndex = 0
                }

                for repo in self.allRepos.prefix(10) {
                    fetchLanguages(for: repo)
                }
            }
        }.resume()
    }

    private func fetchLanguages(for repo: Repo) {
        guard let url = URL(string: repo.languagesURL) else { return }

        var request = URLRequest(url: url)

        if let token = auth.accessToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        URLSession.shared.dataTask(with: request) { data, _, _ in
            guard let data = data else {
                print("X No language data for repo:", repo.name)
                return
            }

            guard let languageDict = try? JSONSerialization.jsonObject(with: data) as? [String: Int] else {
                print("x Language JSON parse failed for repo:", repo.name)
                print(String(data: data, encoding: .utf8) ?? "No readable body")
                return
            }

            print("Languages fetched for:", repo.name, "| Count:", languageDict.count)

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
                // Find repo by id instead of index (prevents mismatch after shuffle)
                if let repoIndex = self.allRepos.firstIndex(where: { $0.id == repo.id }) {
                    self.allRepos[repoIndex].languages = mappedLanguages
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
