//
//  BackgroundView.swift
//  _gitinder
//
//  Created by Osman Kahraman on 2026-05-07.
//

import SwiftUI

struct BackgroundView: View {
    let dragOffset: CGFloat

    var body: some View {
        Color.black
            .overlay(
                Color.green.opacity(
                    dragOffset > 0
                    ? min(Double(dragOffset / 150), 0.4)
                    : 0
                )
            )
            .overlay(
                Color.red.opacity(
                    dragOffset < 0
                    ? min(Double(-dragOffset / 150), 0.4)
                    : 0
                )
            )
            .ignoresSafeArea()
    }
}
