//
//  _gitinderApp.swift
//  _gitinder
//
//  Created by Osman Kahraman on 2026-02-25.
//

import SwiftUI

@main
struct GitSwipeApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var auth = AuthManager()
    private let credentialsStore = CredentialsStore()
    private let gitHubAuthClient = GitHubAuthClient()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(auth)
                .onOpenURL { url in
                    handleGitHubCallback(url: url)
                }
                .onChange(of: scenePhase) { _, newPhase in
                    if newPhase == .inactive || newPhase == .background {
                        auth.syncStarChanges()
                    }
                }
        }
    }

    private func handleGitHubCallback(url: URL) {
        guard url.scheme == "gitinder" else { return }

        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        guard let code = components?.queryItems?.first(where: { $0.name == "code" })?.value else {
            print("No OAuth code")
            return
        }

        Task {
            await exchangeCodeForToken(code: code)
        }
    }

    private func exchangeCodeForToken(code: String) async {
        do {
            let accessToken = try await gitHubAuthClient.exchangeCodeForToken(code)
            credentialsStore.saveAccessToken(accessToken)
            await MainActor.run {
                auth.accessToken = accessToken
            }
            await auth.fetchGitHubUser()
        } catch {
            print("Token exchange failed:", error)
        }
    }
}
