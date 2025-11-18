import Foundation
import UIKit

@MainActor
protocol HapticsServiceProtocol {
    func success()
    func review()
    func flip()
}

@MainActor
final class HapticsService: HapticsServiceProtocol {

    static let shared = HapticsService()

    private let notificationGenerator = UINotificationFeedbackGenerator()
    private let softImpactGenerator = UIImpactFeedbackGenerator(style: .soft)

    private init() {
        // Pre-warm generators so first haptic feels snappy
        notificationGenerator.prepare()
        softImpactGenerator.prepare()
    }

    func success() {
        notificationGenerator.notificationOccurred(.success)
    }

    func review() {
        notificationGenerator.notificationOccurred(.warning)
    }

    func flip() {
        softImpactGenerator.impactOccurred()
    }
}
