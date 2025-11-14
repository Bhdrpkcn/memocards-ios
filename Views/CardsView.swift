import SwiftUI

struct CardsView: View {

    var cards: [Color] = [
        Color(red: 0.89, green: 0.49, blue: 0.36),
        Color(red: 0.98, green: 0.76, blue: 0.44),
        Color(red: 0.58, green: 0.82, blue: 0.62),
        Color(red: 0.44, green: 0.72, blue: 0.84),
        Color(red: 0.64, green: 0.56, blue: 0.87),
    ]

    @State private var dragOffset: CGSize = .zero
    @State private var topCardIndex: Int = 0

    var width: CGFloat = 180

    var body: some View {
        ZStack {
            ForEach(cards.indices, id: \.self) { index in
                let visualIndex = (index - topCardIndex + cards.count) % cards.count

                let progress = min(abs(dragOffset.width) / 150, 1)

                let signedProgress = (dragOffset.width >= 0 ? 1 : -1) * progress

                RoundedRectangle(cornerRadius: 16)
                    .frame(width: width, height: 250)
                    .foregroundStyle(cards[index])
                    .offset(
                        x: visualIndex == 0 ? dragOffset.width : Double(visualIndex) * 10,
                        y: visualIndex == 0 ? 0 : Double(visualIndex) * -4
                    )
                    .zIndex(Double(cards.count - visualIndex))
                    .rotationEffect(
                        .degrees(visualIndex == 0 ? 0 : Double(visualIndex) * 3 - progress * 3),
                        anchor: .bottom
                    )
                    .scaleEffect( visualIndex == 0 ? 1.0 : visualIndex == 1
                                ? (1.0 - Double(visualIndex) * 0.06 + progress * 0.06)
                                : (1.0 - Double(visualIndex) * 0.06)
                    )
                    .offset(x: visualIndex == 0 ? 0 : Double(visualIndex) * -3)
                    .rotation3DEffect(
                        .degrees(
                            (visualIndex == 0 || visualIndex == 1) ? 10 * signedProgress : 0
                        ),
                        axis: (0, 1, 0)
                    )
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                dragOffset = value.translation
                            }
                            .onEnded { value in
                                let threshold: CGFloat = 50
                                let direction: CGFloat = value.translation.width > 0 ? 1 : -1
                                let delay = direction < 0 ? 0.18 : 0.20

                                if abs(value.translation.width) > threshold {
                                    let direction: CGFloat = value.translation.width > 0 ? 1 : -1

                                    withAnimation(.smooth(duration: 0.2)) {
                                        dragOffset.width = direction < 0 ? -width : width * 1.33
                                    }

                                    DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                                        withAnimation(.smooth(duration: 0.5)) {
                                            topCardIndex = (topCardIndex + 1) % cards.count
                                            dragOffset = .zero
                                        }
                                    }
                                } else {
                                    withAnimation {
                                        dragOffset = .zero
                                    }
                                }
                            }
                    )

            }
        }
    }
}

#Preview {
    CardsView()
}
