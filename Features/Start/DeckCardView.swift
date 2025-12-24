import SwiftUI

struct DeckCardView: View {

    let deck: Deck
    @Binding var isFlipped: Bool
    let height: CGFloat
    let width: CGFloat

    var body: some View {
        CardShell(
            isFlipped: $isFlipped,
            height: height,
            width: width
        ) {
            RoundedRectangle(cornerRadius: AppTheme.Layout.cardCornerRadius, style: .continuous)
                .fill(AppTheme.Colors.deckBackground(for: deck).gradient).shadow(
                    radius: AppTheme.Shadows.card.radius
                )
        } front: {
            front
        } back: {
            back
        }
    }

    // MARK: - Front View
    private var front: some View {
        VStack(spacing: 10) {
            Spacer()

            Text(deck.name)
                .font(.title3.bold())
                .foregroundColor(AppTheme.Colors.textPrimary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 18)

            chip

            if let desc = deck.description, !desc.isEmpty {
                Text(desc)
                    .font(.caption)
                    .foregroundColor(AppTheme.Colors.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                    .padding(.horizontal, 18)
            }

            Spacer()

            HStack {
                Spacer()
                HStack(spacing: 4) {
                    Image(systemName: "hand.tap")
                        .font(.caption)
                    Text("Tap for details")
                        .font(.caption)
                }
                .foregroundColor(AppTheme.Colors.textSecondary)
            }
            .padding(.horizontal, AppTheme.Layout.standardPadding)
            .padding(.bottom, 18)
        }
    }

    // MARK: - Back View
    private var back: some View {
        VStack(spacing: 12) {
            Spacer()

            Text("Deck details")
                .font(.caption)
                .foregroundColor(AppTheme.Colors.textSecondary)

            Text(deck.name)
                .font(.title3.bold())
                .foregroundColor(AppTheme.Colors.textPrimary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 18)

            VStack(spacing: 8) {
                if deck.isCustom {
                    detailRow(label: "Type", value: "Your collection")
                } else if let diff = deck.difficulty {
                    detailRow(label: "Difficulty", value: diff.rawValue.capitalized)
                }

                detailRow(label: "Words", value: deck.cardCount.map(String.init) ?? "—")

                detailRow(
                    label: "Languages",
                    value:
                        "\(deck.fromLanguageCode.uppercased()) → \(deck.toLanguageCode.uppercased())"
                )
            }
            .padding(.horizontal, AppTheme.Layout.standardPadding)

            Spacer()

            Divider()
                .overlay(AppTheme.Colors.textSecondary)

            Text("Tap to flip back")
                .font(.caption)
                .foregroundColor(AppTheme.Colors.textSecondary)
        }
        .padding(AppTheme.Layout.standardPadding)
        .foregroundColor(AppTheme.Colors.textPrimary)
    }

    // MARK: - Components
    private var chip: some View {
        Group {
            if deck.isCustom {
                Text("Your collection")
                    .chipStyle()
            } else if let difficulty = deck.difficulty {
                Text(difficulty.rawValue.capitalized)
                    .chipStyle()
            }
        }
    }

    private func detailRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.caption.weight(.semibold))
                .foregroundColor(AppTheme.Colors.textSecondary)
            Spacer()
            Text(value)
                .font(.caption)
                .foregroundColor(AppTheme.Colors.textPrimary)
        }
    }
}

// MARK: - Styles
extension Text {
    fileprivate func chipStyle() -> some View {
        self
            .font(.caption.weight(.semibold))
            .foregroundColor(AppTheme.Colors.textPrimary)
            .padding(.horizontal, AppTheme.Layout.smallPadding)
            .padding(.vertical, 5)
            .background(AppTheme.Colors.cardBackground)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.Layout.chipCornerRadius)
                    .stroke(Color.white.opacity(0.25), lineWidth: 1)
            )
            .cornerRadius(AppTheme.Layout.chipCornerRadius)
    }
}
