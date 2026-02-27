//
//  PreferencesView.swift
//  _gitinder
//
//  Created by Osman Kahraman on 2026-02-27.
//

import SwiftUI

struct PreferencesView: View {

    @EnvironmentObject var auth: AuthManager

    let languages = [
        "Swift", "Python", "JavaScript", "TypeScript", "Go", "Rust", "C++", "C",
        "C#", "Java", "Kotlin", "Dart", "PHP", "Ruby", "Elixir",
        "Scala", "Haskell", "Lua", "Shell", "PowerShell",
        "Objective-C", "Groovy", "Assembly", "R", "MATLAB"
    ]

    @State private var selected: Set<String> = []

    var body: some View {
        VStack(spacing: 24) {

            Text("Select Your Favorite Languages")
                .font(.custom("Doto-Black_Bold", size: 24))
                .foregroundColor(.white)

            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 16) {
                    ForEach(languages, id: \.self) { lang in
                        languageCard(lang)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
            }

            Button(action: {
                let prefs = UserPreferences(selectedLanguages: Array(selected))
                auth.savePreferences(prefs)
            }) {
                Text("Continue")
                    .font(.custom("Doto-Black_Bold", size: 18))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(selected.isEmpty ? Color.gray : Color.green)
                    .cornerRadius(14)
            }
            .disabled(selected.isEmpty)
        }
        .padding()
        .background(Color.black.ignoresSafeArea())
    }

    @ViewBuilder
    func languageCard(_ lang: String) -> some View {
        let isSelected = selected.contains(lang)
        
        Text(lang)
            .font(.custom("Doto-Black_Bold", size: 14))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? Color.green.opacity(0.8) : Color.black)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.green : Color.white.opacity(0.2), lineWidth: isSelected ? 3 : 1)
            )
            .scaleEffect(isSelected ? 1.05 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
            .onTapGesture {
                toggle(lang)
            }
    }

    func toggle(_ lang: String) {
        if selected.contains(lang) {
            selected.remove(lang)
        } else {
            selected.insert(lang)
        }
    }
}

#Preview {
    PreferencesView()
}
