//
//  ProfileView.swift
//  GitSwipe
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

            ScrollView {
                VStack(spacing: 24) {
                    // Header
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

                        Text("iOS Developer • ML Enthusiast • Building _gitinder")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.white.opacity(0.8))
                            .font(.custom("Doto-Black_Bold", size: 14))
                            .padding(.horizontal)
                    }

                    // Stats Section
                    HStack(spacing: 40) {
                        profileStat(title: "Repos", value: "\(auth.publicRepos)")
                        profileStat(title: "Followers", value: "\(auth.followers)")
                        profileStat(title: "Following", value: "\(auth.following)")
                    }

                    Button("Logout") {
                        auth.logout()
                    }
                    .font(.custom("Doto-Black_Bold", size: 14))
                    .padding()
                    .background(Color.red.opacity(0.8))
                    .cornerRadius(8)

                    Divider()
                        .background(Color.white.opacity(0.2))

                    // Lastly Starred Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Lastly Starred Repositories")
                            .font(.custom("Doto-Black_Bold", size: 18))

                        pinnedRepoCard(name: "Awesome Python", description: "A curated collection of high-quality Python libraries and resources.")

                        pinnedRepoCard(name: "Cool ML", description: "Hands-on machine learning implementations and experiments.")

                        pinnedRepoCard(name: "iOS SwiftUI", description: "Modern SwiftUI components and animation patterns.")
                    }
                    .padding(.horizontal)
                }
                .padding(.top, 40)
                .padding(.bottom, 100)
            }
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
                .stroke(Color.white.opacity(0.15), lineWidth: 1)
        )
        .cornerRadius(12)
    }
}

#Preview {
    ProfileView()
}
