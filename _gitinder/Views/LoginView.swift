//
//  LoginView.swift
//  _gitinder
//
//  Created by Osman Kahraman on 2026-02-25.
//

import SwiftUI
import UIKit

struct LoginView: View {
    @EnvironmentObject var auth: AuthManager
    @State private var username: String = ""
    @State private var animatedText: String = ""
    private let words: [String] = ["_gitinder"]
    @State private var currentWordIndex: Int = 0
    @State private var isDeleting: Bool = false

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            VStack(spacing: 28) {
                Text(animatedText)
                    .font(.custom("Doto-Black_ExtraBold", size: 32))
                    .foregroundColor(.white)

                Text("Sign in to continue")
                    .font(.custom("Doto-Black_Bold", size: 14))
                    .foregroundColor(.gray)

                VStack(spacing: 16) {
                    Button(action: {
                        auth.startOAuthLogin()
                    }) {
                        HStack {
                            Image(systemName: "globe")
                            Text("Continue with GitHub")
                                .font(.custom("Doto-Black_Bold", size: 16))
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .foregroundColor(.black)
                        .cornerRadius(12)
                    }
                }
                .padding(.horizontal, 32)
            }
        }
        .onAppear {
            startTypingAnimation()
        }
    }

    private func startTypingAnimation() {
        let baseText = "_git"
        let suffix = "inder"

        Timer.scheduledTimer(withTimeInterval: 0.12, repeats: true) { timer in
            if isDeleting {
                if animatedText.count > baseText.count {
                    animatedText.removeLast()
                } else {
                    isDeleting = false
                }
            } else {
                if animatedText.count < baseText.count + suffix.count {
                    let nextIndex = animatedText.count - baseText.count
                    if animatedText.count < baseText.count {
                        animatedText = baseText
                    } else {
                        let index = suffix.index(suffix.startIndex, offsetBy: nextIndex)
                        animatedText.append(suffix[index])
                    }
                } else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                        isDeleting = true
                    }
                }
            }
        }
    }
}

#Preview {
    LoginView()
}
