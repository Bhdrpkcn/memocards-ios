import SwiftUI

struct CardView: View {

    let card: MemoCard
    let isFlipped: Bool

    var body: some View {
        ZStack {
            // MARK: Back
            cardFace(text: card.backText, subtitle: "Back", color: card.color)
                .opacity(isFlipped ? 1 : 0)
                .rotation3DEffect(
                    .degrees(isFlipped ? 0 : -180),
                    axis: (x: 0, y: 1, z: 0)
                )

            // MARK: Front
            cardFace(text: card.frontText, subtitle: "Front", color: card.color)
                .opacity(isFlipped ? 0 : 1)
                .rotation3DEffect(
                    .degrees(isFlipped ? 180 : 0),
                    axis: (x: 0, y: 1, z: 0)
                )

        }
        .frame(maxWidth: .infinity)
        .frame(height: 260)
        .padding(.horizontal, 24)
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: isFlipped)
    }

    private func cardFace(text: String, subtitle: String, color: Color) -> some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(color.gradient)
                .shadow(radius: 10)

            VStack(alignment: .leading, spacing: 8) {
                Text(subtitle.uppercased())
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.8))

                Text(text)
                    .font(.title2.weight(.semibold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
            }
            .padding(20)
        }
    }
}
