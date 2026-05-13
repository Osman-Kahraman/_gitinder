//
//  ContentView.swift
//  _gitinder
//
//  Created by Osman Kahraman on 2026-02-25.
//


import SwiftUI

struct ContentView: View {
    @EnvironmentObject var auth: AuthManager

    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor.lightGray
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.lightGray]
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor.white
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.white]

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some View {
        Group {
            switch auth.phase {
            case .unauthenticated:
                LoginView()
                    .environmentObject(auth)

            case .loading:
                LoadingView()

            case .error(let message):
                VStack(spacing: 16) {
                    Text(message)
                        .foregroundColor(.white)

                    Button("Try Again") {
                        Task { await auth.fetchGitHubUser() }
                    }
                    .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.black.ignoresSafeArea())

            case .ready:
                if auth.needsOnboarding {
                    LanguagesView(isOnboarding: true)
                        .tint(.white)
                } else {
                    TabView {
                        NavigationStack {
                            HomeView()
                        }
                        .tabItem {
                            Image(systemName: "house.fill")
                            Text("Home")
                        }

                        NavigationStack {
                            ProfileView()
                                .environmentObject(auth)
                        }
                        .tabItem {
                            Image(systemName: "person.fill")
                            Text("Profile")
                        }
                    }
                    .tint(.white)
                }
            }
        }
        .alert("Something went wrong", isPresented: Binding(
            get: { auth.errorMessage != nil },
            set: { if !$0 { auth.errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) { auth.errorMessage = nil }
        } message: {
            Text(auth.errorMessage ?? "")
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthManager())
}
