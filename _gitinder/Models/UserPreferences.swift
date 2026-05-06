//
//  UserPreferences.swift
//  _gitinder
//
//  Created by Osman Kahraman on 2026-02-27.
//

import Foundation

struct UserPreferences: Codable {
    var selectedLanguages: [String] = []
    var starLimit: Int = 100
    var recentlyUpdatedDays: Int = 0
}
