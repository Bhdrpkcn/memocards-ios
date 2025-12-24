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
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(card.color.gradient)
                .shadow(radius: 10)
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
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
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
                .foregroundColor(.white.opacity(0.9))
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 18)
        }
    }

    private var backFace: some View {
        VStack {
            Spacer()

            Text("Answer")
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))

            Text(card.backText)
                .font(.title2.weight(.semibold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 12)

            Spacer()

            Divider()

            Text("Some gramer text will be wroted here")
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
                .padding(12)

            HStack {
                if let difficulty = card.difficulty {
                    difficultyBadge(difficulty)
                }
                Spacer()
            }
        }
        .padding(20)
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
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(Capsule().fill(Color.white.opacity(0.18)))
            .overlay(Capsule().stroke(Color.white.opacity(0.4), lineWidth: 1))
            .foregroundColor(.white)
    }
}
