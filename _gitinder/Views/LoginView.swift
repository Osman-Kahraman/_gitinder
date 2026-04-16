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
    @State private var currentWordIndex: Int = 0
    @State private var isDeleting: Bool = false
    @State private var showSafari = false
    @State private var authURL: URL?

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            VStack(spacing: 28) {
                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 160, height: 160)
                
                Text(animatedText)
                    .font(.custom("Doto-Black_ExtraBold", size: 32))
                    .foregroundColor(.white)

                Text("Sign in to continue")
                    .font(.custom("Doto-Black_Bold", size: 14))
                    .foregroundColor(.gray)

                VStack(spacing: 16) {
                    Button(action: {
                        if let url = auth.getOAuthURL() {
                            authURL = url
                            showSafari = true
                        }
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
                    
                    Button(action: {
                        auth.loginAsDemo()
                    }) {
                        HStack {
                            Image(systemName: "person.fill")
                            Text("Continue as Guest")
                                .font(.custom("Doto-Black_Bold", size: 16))
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                }
                .padding(.horizontal, 32)

                HStack(spacing: 4) {
                    Text("built by")
                        .font(.custom("Doto-Black_Bold", size: 10))
                        .foregroundColor(.gray)

                    Link("@Osman-Kahraman", destination: URL(string: "https://github.com/Osman-Kahraman")!)
                        .font(.custom("Doto-Black_Bold", size: 10))
                        .foregroundColor(.white)
                }
                .padding(.top, 16)
            }
        }
        .sheet(isPresented: $showSafari) {
            if let url = authURL {
                SafariView(url: url)
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
