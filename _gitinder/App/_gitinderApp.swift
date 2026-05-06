//
//  _gitinderApp.swift
//  _gitinder
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
        guard let code = components?.queryItems?.first(where: { $0.name == "code" })?.value else {
            print("No OAuth code")
            return
        }

        Task {
            await exchangeCodeForToken(code: code)
        }
    }

    private func exchangeCodeForToken(code: String) async {
        guard let url = URL(string: "https://gitinder-auth.onrender.com/oauth/exchange") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = ["code": code]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let accessToken = json["access_token"] as? String else {
                print("Token exchange failed")
                return
            }

            KeychainManager.shared.save(key: "github_access_token", value: accessToken)
            await MainActor.run {
                auth.accessToken = accessToken
            }
            await auth.fetchGitHubUser()
        } catch {
            print("Token exchange error:", error)
        }
    }
}
