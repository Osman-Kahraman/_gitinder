//
//  StarState.swift
//  _gitinder
//
//  Created by Osman Kahraman on 2026-03-09.
//

import Foundation

struct RepoReference: Hashable, Codable {
    let owner: String
    let name: String
}

struct StarState {
    var starredRepos: [Repo] = []
    var localStarredRepos: [Repo] = []
    var pendingStars: [RepoReference] = []
    var pendingUnstars: [RepoReference] = []
}
