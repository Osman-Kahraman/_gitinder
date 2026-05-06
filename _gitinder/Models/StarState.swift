//
//  StarState.swift
//  _gitinder
//
//  Created by Osman Kahraman on 2026-03-09.
//

import Foundation

struct StarState {
    var starredRepos: [Repo] = []
    var localStarredRepos: [Repo] = []
    var pendingStars: [(owner: String, repo: String)] = []
    var pendingUnstars: [(owner: String, repo: String)] = []
}
