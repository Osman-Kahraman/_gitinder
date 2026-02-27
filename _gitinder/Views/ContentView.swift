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
                if auth.preferences == nil {
                    PreferencesView()
                        .tint(.white)
                } else {
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
