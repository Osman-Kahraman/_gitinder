//
//  CredentialsStore.swift
//  _gitinder
//
//  Created by Osman Kahraman on 2026-03-09.
//

import Foundation

final class CredentialsStore {
    private let accessTokenKey = "github_access_token"

    func loadAccessToken() -> String? {
        KeychainManager.shared.read(key: accessTokenKey)
    }

    func saveAccessToken(_ token: String) {
        KeychainManager.shared.save(key: accessTokenKey, value: token)
    }

    func clearAccessToken() {
        KeychainManager.shared.delete(key: accessTokenKey)
    }
}
