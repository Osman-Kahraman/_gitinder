//
//  LoadingView.swift
//  _gitinder
//
//  Created by Osman Kahraman on 2026-05-05.
//


import SwiftUI

struct LoadingView: View {
    @State private var tipIndex = 0
    private let tips = [
        "Tip: Swipe right to star repositories instantly.",
        "Tip: Use filters to find repos in your favorite languages.",
        "Tip: Recently updated repos are more active.",
        "Tip: Smaller repos can hide real gems.",
        "Tip: Try different star limits for better discovery."
    ]
    var loadingTip: String {
        tips[tipIndex % tips.count]
    }
    
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                .scaleEffect(1.4)

            Text("Finding great repositories for you...")
                .foregroundColor(.white)
                .font(.custom("Doto-Black_Bold", size: 16))

            Text(loadingTip)
                .foregroundColor(.gray)
                .font(.custom("Doto-Black", size: 13))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
                .transition(.opacity)
        }
        .onAppear {
            startTipRotation()
        }
    }

    func startTipRotation() {
        Timer.scheduledTimer(withTimeInterval: 8.0, repeats: true) { _ in
            withAnimation {
                tipIndex += 1
            }
        }
    }
}
