//
//  GitHubHTTPClient.swift
//  _gitinder
//
//  Created by Osman Kahraman on 2026-05-05.
//

import Foundation

enum GitHubHTTPClient {
    static func makeRequest(
        urlString: String,
        method: String = "GET",
        token: String? = nil,
        body: Data? = nil,
        additionalHeaders: [String: String] = [:]
    ) throws -> URLRequest {
        guard let url = URL(string: urlString) else {
            throw GitHubClientError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")

        if let token = token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        for (field, value) in additionalHeaders {
            request.setValue(value, forHTTPHeaderField: field)
        }

        request.httpBody = body
        return request
    }

    static func data(for request: URLRequest) async throws -> Data {
        let (data, response) = try await rawData(for: request)
        try validate(response)
        return data
    }

    static func rawData(for request: URLRequest) async throws -> (Data, URLResponse) {
        do {
            return try await URLSession.shared.data(for: request)
        } catch let error as GitHubClientError {
            throw error
        } catch {
            throw GitHubClientError.network(error)
        }
    }

    static func validate(_ response: URLResponse) throws {
        guard let http = response as? HTTPURLResponse else {
            throw GitHubClientError.invalidResponse
        }

        switch http.statusCode {
        case 200...299:
            return
        case 401:
            throw GitHubClientError.unauthorized
        case 403:
            throw GitHubClientError.rateLimited
        case 500...599:
            throw GitHubClientError.serverError(http.statusCode)
        default:
            throw GitHubClientError.invalidResponse
        }
    }

    static func isRateLimited(_ response: URLResponse) -> Bool {
        guard let http = response as? HTTPURLResponse else { return false }
        return http.statusCode == 403
    }
}

enum GitHubClientError: LocalizedError {
    case invalidURL
    case invalidResponse
    case unauthorized
    case rateLimited
    case serverError(Int)
    case network(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            "Invalid GitHub URL."
        case .invalidResponse:
            "GitHub returned an invalid response."
        case .unauthorized:
            "GitHub authorization failed. Please log in again."
        case .rateLimited:
            "GitHub rate limit reached. It will try again 30 seconds later."
        case .serverError(let code):
            "GitHub server error: \(code)."
        case .network:
            "Network connection failed."
        }
    }
}
