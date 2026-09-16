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

            HStack(spacing: 12) {
                Button {
                    description = ""
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
                    auth.saveAIPreferenceDescription(description)
                    dismiss()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "sparkles")
                        Text("Apply")
                    }
                    .font(.custom("Doto-Black_Bold", size: 18))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.gray : Color.green)
                    .cornerRadius(14)
                }
                .disabled(description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .padding()
        .background(Color.black.ignoresSafeArea())
        .onAppear {
            description = auth.preferences.aiPreferenceDescription
        }
    }
}

#Preview {
    AIPreferencesView()
        .environmentObject(AuthController())
}
