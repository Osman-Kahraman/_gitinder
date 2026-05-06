//
//  UserProfile.swift
//  _gitinder
//
//  Created by Osman Kahraman on 2026-02-27.
//

import Foundation

struct UserProfile: Codable, Equatable {
    var username: String = ""
    var avatarURL: String?
    var publicRepos: Int = 0
    var followers: Int = 0
    var following: Int = 0
}
