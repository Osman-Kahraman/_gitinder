//
//  SwipeCardView.swift
//  GitSwipe
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
                    .font(.custom("Doto-Black_Bold", size: 26))
                    .foregroundColor(.white)
                    .shadow(color: .white, radius: 2)
                
                HStack {
                    Image(systemName: "star.fill")
                    Text("\(repo.star)")
                        .font(.custom("Doto-Black_Bold", size: 12))
                        .foregroundColor(.white)
                        .shadow(color: .white, radius: 2)
                    Image("gitFork")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                    Text("\(repo.fork)")
                        .font(.custom("Doto-Black_Bold", size: 12))
                        .foregroundColor(.white)
                        .shadow(color: .white, radius: 2)
                    Text("\(repo.issues) issues need help")
                        .font(.custom("Doto-Black_Bold", size: 12))
                        .foregroundColor(.white)
                        .shadow(color: .white, radius: 2)
                }
            }
            .padding()
            
            
            Text(repo.description)
                .font(.custom("Doto-Black_Bold", size: 16))
                .foregroundColor(.white)
                .padding()

            // Languages Section
            VStack(alignment: .leading, spacing: 8) {
                Text("Languages")
                    .font(.custom("Doto-Black_Bold", size: 14))
                    .foregroundColor(.white)

                GeometryReader { geo in
                    HStack(spacing: 0) {
                        ForEach(repo.languages, id: \.name) { language in
                            Rectangle()
                                .fill(language.color)
                                .frame(width: geo.size.width * (language.percentage / 100))
                        }
                    }
                    .cornerRadius(6)
                }
                .frame(height: 10)

                HStack(spacing: 16) {
                    ForEach(repo.languages, id: \.name) { language in
                        HStack(spacing: 4) {
                            Circle()
                                .fill(language.color)
                                .frame(width: 8, height: 8)
                            Text("\(language.name) \(String(format: "%.1f", language.percentage))%")
                                .font(.custom("Doto-Black_Bold", size: 10))
                                .foregroundColor(.white)
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
        .frame(width: 300, height: 400)
        .background(Color.black)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: offset.width > 0 ? .green : offset.width < 0 ? .red : .white.opacity(0.2), radius: 10)
        .offset(x: offset.width, y: 0)
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
                    Text("STAR ⭐️")
                        .font(.custom("Doto-Black_Bold", size: 18))
                        .foregroundColor(.green)
                        .padding()
                        .background(Color.black.opacity(0.7))
                        .cornerRadius(10)
                        .rotationEffect(.degrees(-20))
                        .opacity(min(Double(offset.width / 100), 1.0))
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                } else if offset.width < 0 {
                    Text("SKIP ❌")
                        .font(.custom("Doto-Black_Bold", size: 18))
                        .foregroundColor(.red)
                        .padding()
                        .background(Color.black.opacity(0.7))
                        .cornerRadius(10)
                        .rotationEffect(.degrees(20))
                        .opacity(min(Double(-offset.width / 100), 1.0))
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                }
            }
        )
    }
    
    func handleSwipe() {
        if offset.width > 100 {
            // Right swipe
            withAnimation {
                offset = CGSize(width: 500, height: 0)
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                onSwipeRight()
                offset = .zero
            }
            
        } else if offset.width < -100 {
            // Left swipe
            withAnimation {
                offset = CGSize(width: -500, height: 0)
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                onSwipeLeft()
                offset = .zero
            }
            
        } else {
            offset = .zero
        }
    }
}
