//
//  SwipeCardView.swift
//  _gitinder
//
//  Created by Osman Kahraman on 2026-02-25.
//

import SwiftUI

struct SwipeCard: View {
    
    let repo: Repo
    var onSwipeLeft: () -> Void
    var onSwipeRight: () -> Void
    var onDragChanged: (CGFloat) -> Void
    var onDragEnded: () -> Void
    
    @State private var offset: CGSize = .zero
    
    var body: some View {
        VStack {
            
            VStack {
                Text(repo.name)
                    .font(.custom("Doto-Black_Bold", size: 30))
                    .foregroundColor(.white)
                    .shadow(color: .white, radius: 2)
                
                HStack(spacing: 12) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    Text("\(repo.star)")
                        .font(.custom("Doto-Black_Bold", size: 12))
                        .foregroundColor(.white)
                    
                    Image("gitFork")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                    
                    Text("\(repo.fork)")
                        .font(.custom("Doto-Black_Bold", size: 12))
                        .foregroundColor(.white)
                    
                    Text("\(repo.issues) issues need help")
                        .font(.custom("Doto-Black_Bold", size: 12))
                        .foregroundColor(.white)
                }
            }
            .padding()
            
            Spacer()
            
            Text(repo.description)
                .font(.custom("Doto-Black_Bold", size: 16))
                .foregroundColor(.white)
                .padding()

            Spacer()
            
            // Languages Section
            VStack(alignment: .leading, spacing: 8) {
                let sortedLanguages = repo.languages.sorted { $0.percentage > $1.percentage }
                let topLanguages = Array(sortedLanguages.prefix(3))
                let othersPercentage = sortedLanguages.dropFirst(3).reduce(0) { $0 + $1.percentage }

                if !repo.languages.isEmpty {
                    Text("Languages")
                        .font(.custom("Doto-Black_Bold", size: 14))
                        .foregroundColor(.white)
                }

                GeometryReader { geo in
                    HStack(spacing: 0) {
                        ForEach(topLanguages, id: \.name) { language in
                            Rectangle()
                                .fill(language.color)
                                .frame(width: geo.size.width * (language.percentage / 100))
                        }

                        if othersPercentage > 0 {
                            Rectangle()
                                .fill(Color.gray.opacity(0.6))
                                .frame(width: geo.size.width * (othersPercentage / 100))
                        }
                    }
                    .cornerRadius(6)
                }
                .frame(height: 10)

                HStack(spacing: 16) {
                    ForEach(topLanguages, id: \.name) { language in
                        HStack(spacing: 4) {
                            Circle()
                                .fill(language.color)
                                .frame(width: 8, height: 8)
                            Text("\(language.name) \(String(format: "%.1f", language.percentage))%")
                                .font(.custom("Doto-Black_Bold", size: 10))
                                .foregroundColor(.white)
                        }
                    }

                    if othersPercentage > 0 {
                        HStack(spacing: 4) {
                            Circle()
                                .fill(Color.gray.opacity(0.6))
                                .frame(width: 8, height: 8)
                            Text("Others \(String(format: "%.1f", othersPercentage))%")
                                .font(.custom("Doto-Black_Bold", size: 10))
                                .foregroundColor(.white)
                        }
                    }
                }
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .frame(width: UIScreen.main.bounds.width * 0.9,
               height: UIScreen.main.bounds.height * 0.65)
        .background(Color.black)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: offset.width > 0 ? .green : offset.width < 0 ? .red : .white.opacity(0.2), radius: 10)
        .offset(x: offset.width)
        .rotationEffect(.degrees(Double(offset.width / 20)))
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    offset = gesture.translation
                    onDragChanged(gesture.translation.width)
                }
                .onEnded { _ in
                    handleSwipe()
                    onDragEnded()
                }
        )
        .animation(.spring(), value: offset)
        .overlay(
            ZStack {
                if offset.width > 0 {
                    let progress = min(Double(offset.width / 120), 1.0)
                    
                    Text("STAR")
                        .font(.custom("Doto-Black_Bold", size: 44))
                        .foregroundColor(.green)
                        .padding(.horizontal, 28)
                        .padding(.vertical, 14)
                        .background(Color.black.opacity(0.8))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.green, lineWidth: 4)
                        )
                        .rotationEffect(.degrees(-18))
                        .scaleEffect(0.6 + progress * 0.6)
                        .opacity(progress)
                        .offset(x: -50, y: -100)
                }
                
                if offset.width < 0 {
                    let progress = min(Double(-offset.width / 120), 1.0)
                    
                    Text("SKIP")
                        .font(.custom("Doto-Black_Bold", size: 44))
                        .foregroundColor(.red)
                        .padding(.horizontal, 28)
                        .padding(.vertical, 14)
                        .background(Color.black.opacity(0.8))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.red, lineWidth: 4)
                        )
                        .rotationEffect(.degrees(18))
                        .scaleEffect(0.6 + progress * 0.6)
                        .opacity(progress)
                        .offset(x: 50, y: -100)
                }
            }
        )
    }
    
    private func handleSwipe() {
        if offset.width > 120 {
            withAnimation {
                offset = CGSize(width: 600, height: 0)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                onSwipeRight()
                offset = .zero
            }
        } else if offset.width < -120 {
            withAnimation {
                offset = CGSize(width: -600, height: 0)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                onSwipeLeft()
                offset = .zero
            }
        } else {
            offset = .zero
        }
    }
}
