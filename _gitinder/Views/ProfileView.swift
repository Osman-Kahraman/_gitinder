//
//  ProfileView.swift
//  _gitinder
//
//  Created by Osman Kahraman on 2026-02-25.
//


import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var auth: AuthManager

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            List {
                // Header Section
                Section {
                    VStack(spacing: 12) {
                        if let avatarURL = auth.avatarURL,
                           let url = URL(string: avatarURL) {
                            AsyncImage(url: url) { image in
                                image
                                    .resizable()
                                    .scaledToFill()
                            } placeholder: {
                                Color.gray.opacity(0.3)
                            }
                            .frame(width: 120, height: 120)
                            .clipShape(Circle())
                        } else {
                            Circle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 120, height: 120)
                                .overlay(
                                    Image(systemName: "person.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 60, height: 60)
                                        .foregroundColor(.white.opacity(0.8))
                                )
                        }

                        Text(auth.username.isEmpty ? "GitHub User" : auth.username)
                            .font(.custom("Doto-Black_ExtraBold", size: 24))

                        Text(auth.username.isEmpty ? "@username" : "@\(auth.username.lowercased())")
                            .foregroundColor(.gray)
                            .font(.custom("Doto-Black_Bold", size: 14))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .listRowBackground(Color.black)
                }

                // Stats Section
                Section {
                    HStack(spacing: 40) {
                        profileStat(title: "Repos", value: "\(auth.publicRepos)")
                        profileStat(title: "Followers", value: "\(auth.followers)")
                        profileStat(title: "Following", value: "\(auth.following)")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .listRowBackground(Color.black)
                }

                // Logout Section
                Section {
                    Button("Logout") {
                        auth.logout()
                    }
                    .font(.custom("Doto-Black_Bold", size: 14))
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red.opacity(0.8))
                    .cornerRadius(8)
                    .listRowBackground(Color.black)
                }

                // Starred Repositories Section
                Section(header:
                    Text("Lastly Starred Repositories (\(auth.localStarredRepos.count))")
                        .font(.custom("Doto-Black_Bold", size: 19))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 6)
                        .background(Color.black)
                        .listRowInsets(EdgeInsets())
                ) {
                    if auth.localStarredRepos.isEmpty {
                        Text("No starred repositories yet.")
                            .foregroundColor(.gray)
                            .font(.custom("Doto-Black_Bold", size: 13))
                            .listRowBackground(Color.black)
                    } else {
                        ForEach(auth.localStarredRepos, id: \.name) { repo in
                            pinnedRepoCard(name: repo.name, description: repo.description)
                                .listRowBackground(Color.black)
                                .swipeActions(edge: .trailing) {
                                    Button(role: .destructive) {
                                        auth.removeLocalStar(owner: repo.owner, repo: repo.name)
                                    } label: {
                                        Label("", systemImage: "star.slash")
                                    }
                                    .tint(.red.opacity(0.8))
                                }
                        }
                    }
                }

            }
            .scrollContentBackground(.hidden)
            .background(Color.black.ignoresSafeArea())
        }
        .onAppear {
            auth.fetchStarredRepositories()
            
            // Only initialize local cache if it hasn't been populated yet
            if auth.localStarredRepos.isEmpty {
                auth.localStarredRepos = auth.starredRepos
            }
        }
        .onDisappear {
            auth.syncStarChanges()
        }
        .font(.custom("Doto-Black_Bold", size: 16))
        .foregroundColor(.white)
    }

    private func profileStat(title: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.custom("Doto-Black_ExtraBold", size: 18))
            Text(title)
                .foregroundColor(.gray)
                .font(.custom("Doto-Black_Bold", size: 12))
        }
    }

    private func pinnedRepoCard(name: String, description: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(name)
                .font(.custom("Doto-Black_ExtraBold", size: 16))

            Text(description)
                .foregroundColor(.white.opacity(0.8))
                .font(.custom("Doto-Black_Bold", size: 13))
        }
        .padding()
        .background(Color.black)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0))
        )
    }
}

#Preview {
    PreviewWrapper()
}

private struct PreviewWrapper: View {
    @StateObject private var auth = AuthManager()

    var body: some View {
        ProfileView()
            .environmentObject(auth)
            .onAppear {
                auth.localStarredRepos = [
                    Repo(name: "swift", description: "The Swift Programming Language", star: 65000, fork: 10000, issues: 5000, lastUpdate: "2026-01-01", languagesURL: "", languages: [], owner: "apple"),
                    Repo(name: "tensorflow", description: "An end-to-end open source machine learning platform", star: 180000, fork: 88000, issues: 9000, lastUpdate: "2026-01-01", languagesURL: "", languages: [], owner: "tensorflow"),
                    Repo(name: "linux", description: "Linux kernel source tree", star: 170000, fork: 55000, issues: 300, lastUpdate: "2026-01-01", languagesURL: "", languages: [], owner: "torvalds")
                ]
            }
    }
}
