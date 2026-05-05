//
//  Repo.swift
//  _gitinder
//
//  Created by Osman Kahraman on 2026-05-05.
//

import SwiftUI

struct Repo: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let star: Int
    let fork: Int
    let issues: Int
    let lastUpdate: String
    let languagesURL: String
    var languages: [Language]
    let owner: String
}
