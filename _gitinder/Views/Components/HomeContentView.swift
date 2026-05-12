//
//  HomeContentView.swift
//  _gitinder
//
//  Created by Osman Kahraman on 2026-05-11.
//

import SwiftUI

struct HomeContentView: View {
    @EnvironmentObject var auth: AuthManager
    @Binding var repos: [Repo]
    @Binding var currentIndex: Int
    let fetchTrendingRepositories: () -> Void

    @State private var dragOffset: CGFloat = 0
    @State private var lastSwipeDirection: CGFloat = 0
    @State private var showLanguagePreferences = false
    @State private var showStarPreferences = false
    @State private var showUpdatedPreferences = false
    @State private var hasLoaded = false
    
    var body: some View {
        VStack {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    Image(systemName: "slider.horizontal.3")
                        .foregroundColor(.gray)
                    
                    Button {
                        withAnimation(.spring()) {
                            showLanguagePreferences.toggle()
                        }
                    } label: {
                        HStack {
                            Text("Languages")
                                .foregroundColor(.white)
                                .font(.custom("Doto-Black_ExtraBold", size: 14))
                            
                            Spacer()
                            
                            Image(systemName: "chevron.down")
                                .foregroundColor(.white)
                                .rotationEffect(.degrees(showLanguagePreferences ? 180 : 0))
                                .animation(.easeInOut(duration: 0.3), value: showLanguagePreferences)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color.black)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.white.opacity(0.8), lineWidth: 1.5)
                        )
                        .cornerRadius(14)
                        .frame(width: 150)
                    }
                    
                    Button {
                        withAnimation(.spring()) {
                            showStarPreferences.toggle()
                        }
                    } label: {
                        HStack {
                            Text("Star Limit")
                                .foregroundColor(.white)
                                .font(.custom("Doto-Black_ExtraBold", size: 14))
                            
                            Spacer()
                            
                            Image(systemName: "chevron.down")
                                .foregroundColor(.white)
                                .rotationEffect(.degrees(showStarPreferences ? 180 : 0))
                                .animation(.easeInOut(duration: 0.3), value: showStarPreferences)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color.black)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.white.opacity(0.8), lineWidth: 1.5)
                        )
                        .cornerRadius(14)
                        .frame(width: 150)
                    }
                    
                    Button {
                        withAnimation(.spring()) {
                            showUpdatedPreferences.toggle()
                        }
                    } label: {
                        HStack {
                            Text("Last Updated")
                                .foregroundColor(.white)
                                .font(.custom("Doto-Black_ExtraBold", size: 14))
                            
                            Spacer()
                            
                            Image(systemName: "chevron.down")
                                .foregroundColor(.white)
                                .rotationEffect(.degrees(showUpdatedPreferences ? 180 : 0))
                                .animation(.easeInOut(duration: 0.3), value: showUpdatedPreferences)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color.black)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.white.opacity(0.8), lineWidth: 1.5)
                        )
                        .cornerRadius(14)
                        .frame(width: 180)
                    }
                }
                .padding(.horizontal)
            }
            
            Spacer()
            
            if currentIndex < repos.count {
                ZStack {
                    SwipeCard(
                        repo: repos.indices.contains(currentIndex) ? repos[currentIndex] : repos[0],
                        onSwipeLeft: {
                            lastSwipeDirection = -1
                            
                            guard currentIndex < repos.count else { return }
                            let repo = repos[currentIndex]
                            auth.addRepoToBlacklist(owner: repo.owner, repo: repo.name)
                            
                            nextCard()
                        },
                        onSwipeRight: {
                            lastSwipeDirection = 1
                            
                            guard currentIndex < repos.count else { return }
                            guard currentIndex >= 0 else { return }
                            let repo = repos[currentIndex]
                            auth.addLocalStar(repo: repo)
                            
                            nextCard()
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
                LoadingView()
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            BackgroundView(dragOffset: dragOffset)
        )
        .animation(.easeOut(duration: 0.6), value: dragOffset)
        .animation(.spring(), value: currentIndex)
        .sheet(isPresented: $showLanguagePreferences) {
            LanguagesView()
                .environmentObject(auth)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
                .presentationBackground(.black)
        }
        .sheet(isPresented: $showStarPreferences) {
            StarLimitView()
                .environmentObject(auth)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
                .presentationBackground(.black)
        }
        .sheet(isPresented: $showUpdatedPreferences) {
            RecentlyUpdatedView()
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
                .presentationBackground(.black)
        }
        .onAppear {
            if !hasLoaded {
                fetchTrendingRepositories()
                hasLoaded = true
            }
        }
        .onReceive(auth.$preferences) { _ in
            // Refetch whenever preferences object changes
            fetchTrendingRepositories()
        }
        .onDisappear {
            auth.syncStarChanges()
        }
    }
    
    func nextCard() {
        withAnimation(.spring()) {
            var nextIndex = currentIndex + 1

            // Skip any repos that are already blacklisted
            while nextIndex < repos.count {
                let repo = repos[nextIndex]
                if !auth.isRepoBlacklisted(owner: repo.owner, repo: repo.name) {
                    break
                }
                nextIndex += 1
            }

            if nextIndex < repos.count {
                currentIndex = nextIndex

                // Prefetch when approaching end (last 5 cards)
                if currentIndex >= repos.count - 5 {
                    print("Prefetch triggered...")
                    fetchTrendingRepositories()
                }
            } else {
                // Fallback if somehow reached absolute end
                print("Reached end of cards, fetching more...")
                fetchTrendingRepositories()
            }
        }
    }
}
