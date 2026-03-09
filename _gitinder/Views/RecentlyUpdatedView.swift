//
//  RecentlyUpdatedView.swift
//  _gitinder
//
//  Created by Osman Kahraman on 2026-03-09.
//

import SwiftUI

struct RecentlyUpdatedView: View {

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var auth: AuthManager

    @State private var selection: Int = 0

    let options: [(String, Int)] = [
        ("Any time", 0),
        ("Last 24 hours", 1),
        ("Last 7 days", 7),
        ("Last 30 days", 30)
    ]

    var body: some View {
        VStack(spacing: 24) {

            Text("Recently Updated")
                .font(.custom("Doto-Black_Bold", size: 24))
                .foregroundColor(.white)

            ForEach(options, id: \.1) { option in
                Button {
                    selection = option.1
                } label: {
                    HStack {
                        Text(option.0)
                            .foregroundColor(.white)
                            .font(.custom("Doto-Black_Bold", size: 16))

                        Spacer()

                        if selection == option.1 {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        }
                    }
                    .padding()
                    .background(Color.black)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.white.opacity(0.6), lineWidth: 1)
                    )
                    .cornerRadius(14)
                }
            }

            Button {
                auth.saveRecentlyUpdatedDays(selection)
                dismiss()
            } label: {
                Text("Continue")
                    .font(.custom("Doto-Black_Bold", size: 18))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .cornerRadius(14)
            }
        }
        .padding()
        .background(Color.black.ignoresSafeArea())
        .onAppear {
            selection = auth.recentlyUpdatedDays
        }
    }
}

#Preview {
    RecentlyUpdatedView()
        .environmentObject(AuthManager())
}
