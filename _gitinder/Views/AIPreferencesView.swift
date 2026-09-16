//
//  AIPreferencesView.swift
//  _gitinder
//
//  Created by Osman Kahraman on 2026-09-16.
//

import SwiftUI

struct AIPreferencesView: View {
    @EnvironmentObject var auth: AuthController
    @Environment(\.dismiss) private var dismiss
    @State private var description: String = ""
    @State private var isApplying = false
    @State private var errorMessage: String?

    private let aiClient = AIPreferencesClient()
    private let promptPlaceholder = "Describe what you want to discover..."

    var body: some View {
        VStack(spacing: 20) {
            Text("Ask AI")
                .font(.custom("Doto-Black_Bold", size: 24))
                .foregroundColor(.white)

            ZStack(alignment: .topLeading) {
                TextEditor(text: $description)
                    .font(.custom("Doto-Black_Bold", size: 16))
                    .foregroundColor(.white)
                    .scrollContentBackground(.hidden)
                    .padding(12)
                    .frame(minHeight: 180)
                    .background(Color.white.opacity(0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.white.opacity(0.45), lineWidth: 1)
                    )
                    .cornerRadius(14)

                if description.isEmpty {
                    Text(promptPlaceholder)
                        .font(.custom("Doto-Black_Bold", size: 16))
                        .foregroundColor(.white.opacity(0.45))
                        .padding(.horizontal, 18)
                        .padding(.vertical, 20)
                        .allowsHitTesting(false)
                }
            }

            if let errorMessage {
                Text(errorMessage)
                    .font(.custom("Doto-Black_Bold", size: 13))
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
            }

            HStack(spacing: 12) {
                Button {
                    description = ""
                    errorMessage = nil
                    auth.saveAIPreferenceDescription("")
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 48, height: 48)
                        .background(Color.white.opacity(0.12))
                        .clipShape(Circle())
                }
                .accessibilityLabel("Clear AI preferences")

                Button {
                    applyAIPreferences()
                } label: {
                    HStack(spacing: 8) {
                        if isApplying {
                            ProgressView()
                                .tint(.black)
                        } else {
                            Image(systemName: "sparkles")
                        }

                        Text(isApplying ? "Applying" : "Apply")
                    }
                    .font(.custom("Doto-Black_Bold", size: 18))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(applyButtonColor)
                    .cornerRadius(14)
                }
                .disabled(trimmedDescription.isEmpty || isApplying)
            }
        }
        .padding()
        .background(Color.black.ignoresSafeArea())
        .onAppear {
            description = auth.preferences.aiPreferenceDescription
        }
    }

    private var trimmedDescription: String {
        description.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var applyButtonColor: Color {
        trimmedDescription.isEmpty || isApplying ? Color.gray : Color.green
    }

    private func applyAIPreferences() {
        let requestDescription = trimmedDescription
        guard !requestDescription.isEmpty else { return }

        isApplying = true
        errorMessage = nil

        Task {
            do {
                let response = try await aiClient.generatePreferences(
                    description: requestDescription,
                    currentPreferences: auth.preferences
                )

                var updatedPreferences = auth.preferences
                updatedPreferences.selectedLanguages = response.selectedLanguages
                updatedPreferences.starLimit = response.starLimit
                updatedPreferences.recentlyUpdatedDays = response.recentlyUpdatedDays
                updatedPreferences.aiPreferenceDescription = requestDescription
                updatedPreferences.aiSearchQuery = response.searchQuery

                auth.savePreferences(updatedPreferences)
                dismiss()
            } catch {
                if let localizedError = error as? LocalizedError,
                   let description = localizedError.errorDescription {
                    errorMessage = description
                } else {
                    errorMessage = "Couldn't apply AI preferences."
                }
            }

            isApplying = false
        }
    }
}

#Preview {
    AIPreferencesView()
        .environmentObject(AuthController())
}
