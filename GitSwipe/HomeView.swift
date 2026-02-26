//
//  HomeView.swift
//  GitSwipe
//
//  Created by Osman Kahraman on 2026-02-25.
//


import SwiftUI

struct Language {
    let name: String
    let percentage: Double
    let color: Color
}

struct Repo {
    let name: String
    let description: String
    let star: Int
    let fork: Int
    let issues: Int
    let lastUpdate: String
    let languages: [Language]
}

struct HomeView: View {
    @State private var repos: [Repo] = [
        Repo(
            name: "Awesome Python",
            description: "A carefully curated collection of high-quality Python libraries, frameworks, and learning resources for developers at all levels. Covers web, automation, data science, and more.",
            star: 166, fork: 21, issues: 3, lastUpdate: "2 weeks ago",
            languages: [
                Language(name: "Python", percentage: 92.4, color: .blue),
                Language(name: "Shell", percentage: 5.1, color: .green),
                Language(name: "Other", percentage: 2.5, color: .gray)
            ]
        ),

        Repo(
            name: "Cool ML",
            description: "Practical machine learning implementations including classification, regression, and deep learning examples. Designed for experimentation and hands-on understanding.",
            star: 102, fork: 88, issues: 0, lastUpdate: "1 year ago",
            languages: [
                Language(name: "Python", percentage: 85.0, color: .blue),
                Language(name: "Jupyter", percentage: 10.0, color: .orange),
                Language(name: "Other", percentage: 5.0, color: .gray)
            ]
        ),

        Repo(
            name: "iOS SwiftUI",
            description: "A comprehensive guide to building modern iOS applications using SwiftUI. Includes animations, state management patterns, and production-ready UI components.",
            star: 31, fork: 32, issues: 24, lastUpdate: "7 weeks ago",
            languages: [
                Language(name: "Swift", percentage: 97.3, color: .orange),
                Language(name: "Other", percentage: 2.7, color: .gray)
            ]
        ),

        Repo(
            name: "VisaBot",
            description: "An automation tool built with Python to streamline visa appointment checks and notifications. Focused on reliability, scheduling logic, and background task handling.",
            star: 166, fork: 1, issues: 5, lastUpdate: "3 days ago",
            languages: [
                Language(name: "Python", percentage: 99.7, color: .yellow),
                Language(name: "Other", percentage: 0.3, color: .gray)
            ]
        ),
        Repo(
            name: "Awesome Python",
            description: "A carefully curated collection of high-quality Python libraries, frameworks, and learning resources for developers at all levels. Covers web, automation, data science, and more.",
            star: 166, fork: 21, issues: 3, lastUpdate: "2 weeks ago",
            languages: [
                Language(name: "Python", percentage: 92.4, color: .blue),
                Language(name: "Shell", percentage: 5.1, color: .green),
                Language(name: "Other", percentage: 2.5, color: .gray)
            ]
        ),

        Repo(
            name: "Cool ML",
            description: "Practical machine learning implementations including classification, regression, and deep learning examples. Designed for experimentation and hands-on understanding.",
            star: 102, fork: 88, issues: 0, lastUpdate: "1 year ago",
            languages: [
                Language(name: "Python", percentage: 85.0, color: .blue),
                Language(name: "Jupyter", percentage: 10.0, color: .orange),
                Language(name: "Other", percentage: 5.0, color: .gray)
            ]
        ),

        Repo(
            name: "iOS SwiftUI",
            description: "A comprehensive guide to building modern iOS applications using SwiftUI. Includes animations, state management patterns, and production-ready UI components.",
            star: 31, fork: 32, issues: 24, lastUpdate: "7 weeks ago",
            languages: [
                Language(name: "Swift", percentage: 97.3, color: .orange),
                Language(name: "Other", percentage: 2.7, color: .gray)
            ]
        ),

        Repo(
            name: "VisaBot",
            description: "An automation tool built with Python to streamline visa appointment checks and notifications. Focused on reliability, scheduling logic, and background task handling.",
            star: 166, fork: 1, issues: 5, lastUpdate: "3 days ago",
            languages: [
                Language(name: "Python", percentage: 99.7, color: .yellow),
                Language(name: "Other", percentage: 0.3, color: .gray)
            ]
        ),
        Repo(
            name: "Awesome Python",
            description: "A carefully curated collection of high-quality Python libraries, frameworks, and learning resources for developers at all levels. Covers web, automation, data science, and more.",
            star: 166, fork: 21, issues: 3, lastUpdate: "2 weeks ago",
            languages: [
                Language(name: "Python", percentage: 92.4, color: .blue),
                Language(name: "Shell", percentage: 5.1, color: .green),
                Language(name: "Other", percentage: 2.5, color: .gray)
            ]
        ),

        Repo(
            name: "Cool ML",
            description: "Practical machine learning implementations including classification, regression, and deep learning examples. Designed for experimentation and hands-on understanding.",
            star: 102, fork: 88, issues: 0, lastUpdate: "1 year ago",
            languages: [
                Language(name: "Python", percentage: 85.0, color: .blue),
                Language(name: "Jupyter", percentage: 10.0, color: .orange),
                Language(name: "Other", percentage: 5.0, color: .gray)
            ]
        ),

        Repo(
            name: "iOS SwiftUI",
            description: "A comprehensive guide to building modern iOS applications using SwiftUI. Includes animations, state management patterns, and production-ready UI components.",
            star: 31, fork: 32, issues: 24, lastUpdate: "7 weeks ago",
            languages: [
                Language(name: "Swift", percentage: 97.3, color: .orange),
                Language(name: "Other", percentage: 2.7, color: .gray)
            ]
        ),

        Repo(
            name: "VisaBot",
            description: "An automation tool built with Python to streamline visa appointment checks and notifications. Focused on reliability, scheduling logic, and background task handling.",
            star: 166, fork: 1, issues: 5, lastUpdate: "3 days ago",
            languages: [
                Language(name: "Python", percentage: 99.7, color: .yellow),
                Language(name: "Other", percentage: 0.3, color: .gray)
            ]
        ),
        Repo(
            name: "Awesome Python",
            description: "A carefully curated collection of high-quality Python libraries, frameworks, and learning resources for developers at all levels. Covers web, automation, data science, and more.",
            star: 166, fork: 21, issues: 3, lastUpdate: "2 weeks ago",
            languages: [
                Language(name: "Python", percentage: 92.4, color: .blue),
                Language(name: "Shell", percentage: 5.1, color: .green),
                Language(name: "Other", percentage: 2.5, color: .gray)
            ]
        ),

        Repo(
            name: "Cool ML",
            description: "Practical machine learning implementations including classification, regression, and deep learning examples. Designed for experimentation and hands-on understanding.",
            star: 102, fork: 88, issues: 0, lastUpdate: "1 year ago",
            languages: [
                Language(name: "Python", percentage: 85.0, color: .blue),
                Language(name: "Jupyter", percentage: 10.0, color: .orange),
                Language(name: "Other", percentage: 5.0, color: .gray)
            ]
        ),

        Repo(
            name: "iOS SwiftUI",
            description: "A comprehensive guide to building modern iOS applications using SwiftUI. Includes animations, state management patterns, and production-ready UI components.",
            star: 31, fork: 32, issues: 24, lastUpdate: "7 weeks ago",
            languages: [
                Language(name: "Swift", percentage: 97.3, color: .orange),
                Language(name: "Other", percentage: 2.7, color: .gray)
            ]
        ),

        Repo(
            name: "VisaBot",
            description: "An automation tool built with Python to streamline visa appointment checks and notifications. Focused on reliability, scheduling logic, and background task handling.",
            star: 166, fork: 1, issues: 5, lastUpdate: "3 days ago",
            languages: [
                Language(name: "Python", percentage: 99.7, color: .yellow),
                Language(name: "Other", percentage: 0.3, color: .gray)
            ]
        )
    ]

    @State private var currentIndex = 0
    @State private var dragOffset: CGFloat = 0
    @State private var lastSwipeDirection: CGFloat = 0

    var body: some View {
        ZStack {
            Color.black
                .overlay(
                        LinearGradient(
                            colors: [.red.opacity(0.1), .clear, .clear, .clear, .clear, .clear, .green.opacity(0.1)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                .overlay(
                    Color.green.opacity(dragOffset > 0 ? min(Double(dragOffset / 150), 0.4) : 0)
                )
                .overlay(
                    Color.red.opacity(dragOffset < 0 ? min(Double(-dragOffset / 150), 0.4) : 0)
                )
                .ignoresSafeArea()

            VStack() {
                Text("_gitinder")
                    .foregroundColor(.white)
                    .font(.custom("Doto-Black_ExtraBold", size: 34))

                Spacer()

                if currentIndex < repos.count {
                    ZStack {
                        SwipeCard(
                            repo: repos[currentIndex],
                            onSwipeLeft: {
                                print("Disliked")
                                lastSwipeDirection = -1
                                nextCard()
                                withAnimation(.easeOut(duration: 0.6)) {
                                    dragOffset = 0
                                }
                            },
                            onSwipeRight: {
                                print("Liked (Star)")
                                lastSwipeDirection = 1
                                nextCard()
                                withAnimation(.easeOut(duration: 0.6)) {
                                    dragOffset = 0
                                }
                            },
                            onDragChanged: { value in
                                dragOffset = value
                            },
                            onDragEnded: {
                                withAnimation(.easeOut(duration: 0.6)) {
                                    dragOffset = 0
                                }
                            }
                        )
                        .id(currentIndex)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: lastSwipeDirection > 0 ? .trailing : .leading)
                                .combined(with: .opacity)
                        ))
                    }
                } else {
                    Text("Woah! You reached your limit today, come tomorrow...")
                        .foregroundColor(.white)
                        .font(.custom("Doto-Black_Bold", size: 24))
                }

                Spacer()
            }
        }
        .font(.custom("Doto-Black_Bold", size: 18))
        .foregroundColor(.white)
        .animation(.easeOut(duration: 0.6), value: dragOffset)
        .animation(.spring(), value: currentIndex)
    }

    func nextCard() {
        withAnimation(.spring()) {
            currentIndex += 1
        }
    }
}


#Preview {
    HomeView()
}
