//
//  PreferencesStore.swift
//  _gitinder
//
//  Created by Osman Kahraman on 2026-03-09.
//

import Foundation

final class PreferencesStore {
    private let preferencesKey = "user_preferences"
    private let blacklistKey = "repo_blacklist"

    func loadPreferences() -> UserPreferences {
        guard let data = UserDefaults.standard.data(forKey: preferencesKey),
              let preferences = try? JSONDecoder().decode(UserPreferences.self, from: data) else {
            return UserPreferences()
        }

        return preferences
    }

    func savePreferences(_ preferences: UserPreferences) {
        if let data = try? JSONEncoder().encode(preferences) {
            UserDefaults.standard.set(data, forKey: preferencesKey)
        }
    }

    func clearPreferences() {
        UserDefaults.standard.removeObject(forKey: preferencesKey)
    }

    func loadBlacklist() -> Set<String> {
        guard let saved = UserDefaults.standard.array(forKey: blacklistKey) as? [String] else {
            return []
        }

        return Set(saved)
    }

    func saveBlacklist(_ blacklist: Set<String>) {
        UserDefaults.standard.set(Array(blacklist), forKey: blacklistKey)
    }
}
