//
//  ProfileView.swift
//  _gitinder
//
//  Created by Osman Kahraman on 2026-02-25.
//


import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var auth: AuthManager

    private let githubLanguageColors: [String: Color] = [
        "Swift": Color(red: 1.0, green: 0.45, blue: 0.0),
        "Python": Color(red: 0.21, green: 0.36, blue: 0.63),
        "JavaScript": Color(red: 0.95, green: 0.85, blue: 0.2),
        "TypeScript": Color(red: 0.2, green: 0.45, blue: 0.85),
        "Java": Color(red: 0.69, green: 0.13, blue: 0.13),
        "C++": Color(red: 0.0, green: 0.48, blue: 0.8),
        "C": Color(red: 0.33, green: 0.33, blue: 0.33),
        "Go": Color(red: 0.0, green: 0.68, blue: 0.71),
        "Rust": Color(red: 0.87, green: 0.4, blue: 0.2),
        "Kotlin": Color(red: 0.6, green: 0.2, blue: 0.8),
        "PHP": Color(red: 0.47, green: 0.53, blue: 0.8),
        "Dart": Color(red: 0.0, green: 0.6, blue: 0.8)
    ]

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

                    // Preferences Section
                    if let prefs = auth.preferences {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Your Languages")
                                .font(.custom("Doto-Black_Bold", size: 18))
                            

                            if prefs.selectedLanguages.isEmpty {
                                Text("No preferred languages selected.")
                                    .foregroundColor(.gray)
                                    .font(.custom("Doto-Black_Bold", size: 13))
                            } else {
                                LazyVGrid(columns: [GridItem(.adaptive(minimum: 130))], spacing: 14) {
                                    ForEach(prefs.selectedLanguages, id: \.self) { language in
                                        Text(language)
                                            .font(.custom("Doto-Black_Bold", size: 14))
                                            .padding(.vertical, 10)
                                            .padding(.horizontal, 18)
                                            .background(Color.black)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 20)
                                                    .stroke(githubLanguageColors[language] ?? Color.gray, lineWidth: 2)
                                                    .shadow(color: (githubLanguageColors[language] ?? Color.gray).opacity(0.9), radius: 6)
                                            )
                                            .foregroundColor(githubLanguageColors[language] ?? .white)
                                    }
                                    NavigationLink(destination: PreferencesView()) {
                                        Image(systemName: "plus")
                                            .font(.system(size: 16, weight: .bold))
                                            .padding(.vertical, 10)
                                            .padding(.horizontal, 20)
                                            .background(Color.black)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 20)
                                                    .stroke(Color.white.opacity(0.4), lineWidth: 2)
                                                    .shadow(color: Color.white.opacity(0.6), radius: 6)
                                            )
                                            .foregroundColor(.white)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }

                    Divider()
                        .background(Color.white.opacity(0.2))

                    // Lastly Starred Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Lastly Starred Repositories")
                            .font(.custom("Doto-Black_Bold", size: 18))

                        if auth.starredRepos.isEmpty {
                            Text("No starred repositories yet.")
                                .foregroundColor(.gray)
                                .font(.custom("Doto-Black_Bold", size: 13))
                        } else {
                            ForEach(auth.starredRepos, id: \.name) { repo in
                                pinnedRepoCard(name: repo.name, description: repo.description)
                            }
                        }
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
        .environmentObject(AuthManager())
}
