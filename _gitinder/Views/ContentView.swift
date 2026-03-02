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
            if auth.isLoggedIn {
                if auth.needsOnboarding {
                    PreferencesView(isOnboarding: true)
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
