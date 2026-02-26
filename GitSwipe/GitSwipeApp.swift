//
//  GitSwipeApp.swift
//  GitSwipe
//
//  Created by Osman Kahraman on 2026-02-25.
//

import SwiftUI

@main
struct GitSwipeApp: App {

    @StateObject private var auth = AuthManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(auth)
                .onOpenURL { url in
                    handleGitHubCallback(url: url)
                }
        }
    }

    private func handleGitHubCallback(url: URL) {
        guard url.scheme == "gitinder" else { return }

        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        let code = components?.queryItems?.first(where: { $0.name == "code" })?.value

        print("OAuth Code:", code ?? "nil")

        if let _ = code {
            auth.login(username: "GitHubUser") // şimdilik test
        }
    }
}
