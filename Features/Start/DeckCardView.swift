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
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(backgroundColor.gradient)
                .shadow(radius: 10)
        } front: {
            front
        } back: {
            back
        }
    }

    private var backgroundColor: Color {
        if deck.isCustom { return .green }
        switch deck.difficulty {
        case .easy: return .blue
        case .medium: return .orange
        case .hard: return .purple
        case .none: return .blue
        }
    }

    private var front: some View {
        VStack(spacing: 10) {
            Spacer()

            Text(deck.name)
                .font(.title3.bold())
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 18)

            chip

            if let desc = deck.description, !desc.isEmpty {
                Text(desc)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.92))
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
                .foregroundColor(.white.opacity(0.9))
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 18)
        }
    }

    private var back: some View {
        VStack(spacing: 12) {
            Spacer()

            Text("Deck details")
                .font(.caption)
                .foregroundColor(.white.opacity(0.85))

            Text(deck.name)
                .font(.title3.bold())
                .foregroundColor(.white)
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
                    value: "\(deck.fromLanguageCode.uppercased()) → \(deck.toLanguageCode.uppercased())"
                )
            }
            .padding(.horizontal, 20)

            Spacer()

            Divider()

            Text("Tap to flip back")
                .font(.caption)
                .foregroundColor(.white.opacity(0.85))
        }
        .padding(20)
        .foregroundColor(.white)
    }

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
                .foregroundColor(.white.opacity(0.85))
            Spacer()
            Text(value)
                .font(.caption)
                .foregroundColor(.white)
        }
    }
}

private extension Text {
    func chipStyle() -> some View {
        self
            .font(.caption.weight(.semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Color.white.opacity(0.18))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.white.opacity(0.25), lineWidth: 1)
            )
            .cornerRadius(10)
    }
}
