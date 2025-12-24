import SwiftUI

struct WordCardView: View {

    let card: MemoCard
    @Binding var isFlipped: Bool
    let height: CGFloat

    var body: some View {
        CardShell(
            isFlipped: $isFlipped,
            height: height
        ) {
            RoundedRectangle(cornerRadius: AppTheme.Layout.cardCornerRadius, style: .continuous)
                .fill(card.color.gradient)
                .shadow(radius: AppTheme.Shadows.card.radius)
        } front: {
            frontFace
        } back: {
            backFace
        }
    }

    private var frontFace: some View {
        VStack {
            Spacer()

            Text(card.frontText)
                .font(.title2.weight(.semibold))
                .foregroundColor(AppTheme.Colors.textPrimary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppTheme.Layout.standardPadding)
                .padding(.bottom, 12)

            Spacer()

            HStack {
                if let difficulty = card.difficulty {
                    difficultyBadge(difficulty)
                }

                Spacer()

                HStack(spacing: 4) {
                    Image(systemName: "hand.tap")
                        .font(.caption)
                    Text("Tap to flip")
                        .font(.caption)
                }
                .foregroundColor(AppTheme.Colors.textSecondary)
            }
            .padding(.horizontal, AppTheme.Layout.standardPadding)
            .padding(.bottom, 18)
        }
    }

    private var backFace: some View {
        VStack {
            Spacer()

            Text("Answer")
                .font(.caption)
                .foregroundColor(AppTheme.Colors.textSecondary)

            Text(card.backText)
                .font(.title2.weight(.semibold))
                .foregroundColor(AppTheme.Colors.textPrimary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 12)

            Spacer()

            Divider()
                .overlay(AppTheme.Colors.textSecondary)

            Text("Some grammar text will be written here")
                .font(.caption)
                .foregroundColor(AppTheme.Colors.textSecondary)
                .padding(12)

            HStack {
                if let difficulty = card.difficulty {
                    difficultyBadge(difficulty)
                }
                Spacer()
            }
        }
        .padding(AppTheme.Layout.standardPadding)
    }

    private func difficultyBadge(_ difficulty: CardDifficulty) -> some View {
        let label: String
        switch difficulty {
        case .easy: label = "Easy"
        case .medium: label = "Medium"
        case .hard: label = "Hard"
        }

        return Text(label)
            .font(.caption2.bold())
            .padding(.horizontal, AppTheme.Layout.smallPadding)
            .padding(.vertical, 4)
            .background(Capsule().fill(AppTheme.Colors.cardBackground))
            .overlay(Capsule().stroke(Color.white.opacity(0.4), lineWidth: 1))
            .foregroundColor(AppTheme.Colors.textPrimary)
    }
}
