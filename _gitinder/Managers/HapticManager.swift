//
//  HapticManager.swift
//  _gitinder
//
//  Created by Osman Kahraman on 2026-05-13.
//

import UIKit

final class HapticManager {
    static let shared = HapticManager()

    private init() {}

    func light() {
        let generator = UIImpactFeedbackGenerator(style: .light)

        generator.prepare()
        generator.impactOccurred()
    }

    func medium() {
        let generator = UIImpactFeedbackGenerator(style: .medium)

        generator.prepare()
        generator.impactOccurred()
    }

    func heavy() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)

        generator.prepare()
        generator.impactOccurred()
    }

    func success() {
        let generator = UINotificationFeedbackGenerator()

        generator.prepare()
        generator.notificationOccurred(.success)
    }

    func warning() {
        let generator = UINotificationFeedbackGenerator()

        generator.prepare()
        generator.notificationOccurred(.warning)
    }

    func error() {
        let generator = UINotificationFeedbackGenerator()

        generator.prepare()
        generator.notificationOccurred(.error)
    }
}
