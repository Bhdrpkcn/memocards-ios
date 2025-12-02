import SwiftUI

struct CardView: View {

    let card: MemoCard
    let isFlipped: Bool
    let height: CGFloat

    var body: some View {
        ZStack {
            // MARK: Back
            backFace
                .opacity(isFlipped ? 1 : 0)
                .rotation3DEffect(
                    .degrees(isFlipped ? 0 : -180),
                    axis: (x: 0, y: 1, z: 0)
                )

            // MARK: Front
            frontFace
                .opacity(isFlipped ? 0 : 1)
                .rotation3DEffect(
                    .degrees(isFlipped ? 180 : 0),
                    axis: (x: 0, y: 1, z: 0)
                )
        }
        .frame(maxWidth: .infinity)
        .frame(height: height * 0.9)
        .padding(.horizontal, 24)
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: isFlipped)
    }

    // MARK: - FRONT (Question-like)
    private var frontFace: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(card.color.gradient)
                .shadow(radius: 10)

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
    }

    // MARK: - BACK
    private var backFace: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(card.color.gradient)
                .shadow(radius: 10)

            VStack {
                Spacer()

                Text("Answer")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))

                // Main answer
                Text(card.backText)
                    .font(.title2.weight(.semibold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)

                Spacer()

                Divider()

                // Header / label
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
    }

    // MARK: - Difficulty badge
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
            .background(
                Capsule()
                    .fill(Color.white.opacity(0.18))
            )
            .overlay(
                Capsule()
                    .stroke(Color.white.opacity(0.4), lineWidth: 1)
            )
            .foregroundColor(.white)
    }
}
