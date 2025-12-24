import SwiftUI
import UIKit

struct AppTheme {

    struct Colors {
        // MARK: - Core Palette
        // Soft Mint/Sage
        private static let softGreen = Color(red: 0.56, green: 0.83, blue: 0.60)

        // Peachy Apricot
        private static let softOrange = Color(red: 0.98, green: 0.68, blue: 0.48)

        // Muted Rose/Salmon
        private static let softRed = Color(red: 0.94, green: 0.50, blue: 0.50)

        // Sky/Baby Blue
        private static let softBlue = Color(red: 0.48, green: 0.76, blue: 0.94)

        // Lavender
        private static let softPurple = Color(red: 0.73, green: 0.62, blue: 0.86)

        // Bubblegum/Blush
        private static let softPink = Color(red: 0.98, green: 0.62, blue: 0.76)

        // Creamy Butter
        private static let softYellow = Color(red: 0.96, green: 0.85, blue: 0.45)

        // MARK: - Semantic Colors
        static let primary = softBlue
        static let secondary = softPurple
        static let accent = softOrange
        static let success = softGreen
        static let error = softRed
        static let warning = softYellow
        static let progress = softBlue

        static let cardBackground = Color.white.opacity(0.18)
        static let screenBackground = Color(.systemBackground)
        static let screenSecBackground = Color(white: 0.15)
        static let whiteBackground = Color(.white)
        static let overlayBackground = Color(.black.opacity(0.5))

        static let textPrimary = Color.white
        static let textSecondary = Color.white.opacity(0.90)
        static let disabled = Color.gray.opacity(0.5)

        // MARK: - Coloring Logic

        /// Generates a deck background color based on difficulty (Hue) and ID (Variation)
        static func deckBackground(for deck: Deck) -> Color {
            if deck.isCustom {
                let palette = [
                    softBlue, softGreen, softPurple, softOrange, softPink, softRed, softYellow,
                ]
                let base = palette[abs(deck.id) % palette.count]
                // slight variation to palette colors
                return vary(color: base, seed: deck.id)
            }

            // Premade Decks: Color variations via difficulty levels
            let base: Color
            switch deck.difficulty {
            case .easy:
                base = softGreen
            case .medium:
                base = softOrange
            case .hard:
                base = softRed
            case .none:
                base = softBlue
            }

            return vary(color: base, seed: deck.id)
        }

        static func cardColor(at index: Int) -> Color {
            let palette = [
                softBlue,
                softPurple,
                softPink,
                softRed,
                softOrange,
                softYellow,
                softGreen,
            ]

            let chaoticIndex = (index * 5) % palette.count

            // Color mapping preferences .. Order or Chaotic Order
            // let base = palette[index % palette.count]  // (Cool -> Warm -> Cool)
            let base = palette[chaoticIndex]  // Random Shuffled (palette 7 colors 5 to 7 is coprime)

            // vary based on index
            return vary(color: base, seed: index, variance: 0.05)
        }

        // MARK: - Helper: Color Variation

        private static func vary(color: Color, seed: Int, variance: Double = 0.1) -> Color {
            let uiColor = UIColor(color)
            var h: CGFloat = 0
            var s: CGFloat = 0
            var b: CGFloat = 0
            var a: CGFloat = 0
            uiColor.getHue(&h, saturation: &s, brightness: &b, alpha: &a)

            let noise = sin(Double(seed))

            // Apply small shifts
            let sAdjustment = CGFloat(noise * variance)
            let bAdjustment = CGFloat(noise * (variance / 2.0))

            let newS = max(0.4, min(1.0, s + sAdjustment))  // Clamp Saturation
            let newB = max(0.4, min(1.0, b + bAdjustment))  // Clamp Brightness

            return Color(uiColor: UIColor(hue: h, saturation: newS, brightness: newB, alpha: a))
        }
    }

    struct Layout {
        static let cardCornerRadius: CGFloat = 24
        static let buttonCornerRadius: CGFloat = 14
        static let chipCornerRadius: CGFloat = 10

        static let standardPadding: CGFloat = 20
        static let smallPadding: CGFloat = 10
    }

    struct Shadows {
        static let card = RadiusShadow(radius: 10, y: 0)
    }

    struct RadiusShadow {
        let radius: CGFloat
        let y: CGFloat
    }
}
