//
//  ContentView.swift
//  GitSwipe
//
//  Created by Osman Kahraman on 2026-02-25.
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

    func login(username: String) {
        self.username = username
        self.isLoggedIn = true
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
            }
        }.resume()
    }

    func logout() {
        self.username = ""
        self.isLoggedIn = false
    }
}

struct Repo: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let star: Int
    let fork: Int
    let issues: Int
    let lastUpdate: String
    let languages: [Language]
}

struct Language {
    let name: String
    let percentage: Double
    let color: Color
}

struct ContentView: View {
    @EnvironmentObject var auth: AuthManager
    
    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.black
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor.lightGray
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.lightGray]
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor.white
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.white]

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
    
    var body: some View {
        Group {
            if auth.isLoggedIn {
                TabView {
                    HomeView()
                        .tabItem {
                            Image(systemName: "house.fill")
                            Text("Home")
                        }

                    ProfileView()
                        .environmentObject(auth)
                        .tabItem {
                            Image(systemName: "person.fill")
                            Text("Profile")
                        }
                }
                .tint(.white)
                .toolbarBackground(Color.black, for: .tabBar)
                .toolbarBackground(.visible, for: .tabBar)
                .toolbarColorScheme(.dark, for: .tabBar)
            } else {
                LoginView()
                    .environmentObject(auth)
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthManager())
}
