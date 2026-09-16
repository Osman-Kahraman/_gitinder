//
//  AIPreferencesClient.swift
//  _gitinder
//
//  Created by Codex on 2026-09-16.
//

import Foundation

struct AIPreferenceRequest: Encodable {
    let description: String
    let currentPreferences: UserPreferences
}

struct AIPreferenceResponse: Decodable {
    let selectedLanguages: [String]
    let starLimit: Int
    let recentlyUpdatedDays: Int
    let searchQuery: String
    let reasoningSummary: String
}

final class AIPreferencesClient {
    func generatePreferences(description: String, currentPreferences: UserPreferences) async throws -> AIPreferenceResponse {
        guard let url = aiPreferencesURL else {
            throw AIPreferencesClientError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(
            AIPreferenceRequest(
                description: description,
                currentPreferences: currentPreferences
            )
        )

        let (data, response) = try await URLSession.shared.data(for: request)

        if let httpResponse = response as? HTTPURLResponse,
           !(200...299).contains(httpResponse.statusCode) {
            let message = decodeErrorMessage(from: data) ?? "AI preferences request failed."
            throw AIPreferencesClientError.server(message)
        }

        return try JSONDecoder().decode(AIPreferenceResponse.self, from: data)
    }

    private var aiPreferencesURL: URL? {
        guard let exchangeURLString = Bundle.main.object(forInfoDictionaryKey: "OAUTH_EXCHANGE_URL") as? String else {
            return nil
        }

        let aiURLString: String
        if exchangeURLString.contains("/oauth/exchange") {
            aiURLString = exchangeURLString.replacingOccurrences(of: "/oauth/exchange", with: "/ai/preferences")
        } else {
            aiURLString = exchangeURLString.trimmingCharacters(in: CharacterSet(charactersIn: "/")) + "/ai/preferences"
        }

        return URL(string: aiURLString)
    }

    private func decodeErrorMessage(from data: Data) -> String? {
        guard let payload = try? JSONDecoder().decode(AIErrorResponse.self, from: data) else {
            return nil
        }

        return payload.error
    }
}

private struct AIErrorResponse: Decodable {
    let error: String
}

enum AIPreferencesClientError: LocalizedError {
    case invalidURL
    case server(String)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "AI preferences URL is not configured."
        case .server(let message):
            return message
        }
    }
}
