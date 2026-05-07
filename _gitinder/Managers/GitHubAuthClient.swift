//
//  GitHubAuthClient.swift
//  _gitinder
//
//  Created by Osman Kahraman on 2026-03-09.
//

import Foundation

final class GitHubAuthClient {
    private let exchangeURL = URL(string: "https://gitinder-auth.onrender.com/oauth/exchange")

    func exchangeCodeForToken(_ code: String) async throws -> String {
        guard let exchangeURL else {
            throw GitHubAuthClientError.invalidExchangeURL
        }

        var request = URLRequest(url: exchangeURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: ["code": code])

        let (data, _) = try await URLSession.shared.data(for: request)
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let accessToken = json["access_token"] as? String else {
            throw GitHubAuthClientError.invalidResponse
        }

        return accessToken
    }
}

enum GitHubAuthClientError: Error {
    case invalidExchangeURL
    case invalidResponse
}
