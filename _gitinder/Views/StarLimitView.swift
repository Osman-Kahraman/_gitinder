//
//  StarLimitView.swift
//  _gitinder
//
//  Created by Osman Kahraman on 2026-03-03.
//

import SwiftUI

struct StarLimitView: View {
    @EnvironmentObject var auth: AuthManager
    @Environment(\.dismiss) private var dismiss
    @State private var selectedStarLimit: Int = 100

    var body: some View {
        VStack(spacing: 20) {
            Text("Select Star Limit")
                .font(.custom("Doto-Black_Bold", size: 24))
                .foregroundColor(.white)

            Picker("Stars", selection: $selectedStarLimit) {
                Text("< 10").tag(10)
                Text("< 50").tag(50)
                Text("< 100").tag(100)
                Text("< 500").tag(500)
                Text("< 1000").tag(1000)
                Text("< 5000").tag(5000)
            }
            .pickerStyle(.wheel)
            .labelsHidden()
            .frame(maxWidth: .infinity)
            .background(Color.black)
            .colorScheme(.dark)
            .cornerRadius(12)
            Button(action: {
                auth.saveStarLimit(selectedStarLimit)
                dismiss()
            }) {
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
            selectedStarLimit = auth.starLimit
        }
        .presentationDetents([.fraction(0.3)])
        .presentationDragIndicator(.visible)
    }
}

#Preview {
    StarLimitView()
        .environmentObject(AuthManager())
}
