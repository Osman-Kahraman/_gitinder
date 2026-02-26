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
        guard let code = components?.queryItems?.first(where: { $0.name == "code" })?.value else {
            print("No OAuth code")
            return
        }

        exchangeCodeForToken(code: code)
        
        print("Callback URL:", url)
        print("Code:", code)
    }

    private func exchangeCodeForToken(code: String) {
        let clientID = "Ov23lijhI3pQGO55CMkE"
        let clientSecret = "4cd7b25e825ab5df25736dca91be5b1cbb29dc76"

        guard let url = URL(string: "https://github.com/login/oauth/access_token") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let redirectURI = "gitinder://callback"
        let bodyString = "client_id=\(clientID)&client_secret=\(clientSecret)&code=\(code)&redirect_uri=\(redirectURI)"
        request.httpBody = bodyString.data(using: .utf8)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                print("Raw token response:", String(data: data, encoding: .utf8) ?? "nil")
            }

            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let accessToken = json["access_token"] as? String else {
                print("Token exchange failed")
                return
            }

            DispatchQueue.main.async {
                auth.accessToken = accessToken
                auth.fetchGitHubUser()
            }
        }.resume()
    }
}
