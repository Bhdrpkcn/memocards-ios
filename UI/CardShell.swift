import SwiftUI

struct CardShell<Background: View, Front: View, Back: View>: View {

    @Binding var isFlipped: Bool
    let height: CGFloat
    let width: CGFloat?

    private let background: Background
    private let front: Front
    private let back: Back

    init(
        isFlipped: Binding<Bool>,
        height: CGFloat,
        width: CGFloat? = nil,
        @ViewBuilder background: () -> Background,
        @ViewBuilder front: () -> Front,
        @ViewBuilder back: () -> Back
    ) {
        self._isFlipped = isFlipped
        self.height = height
        self.width = width
        self.background = background()
        self.front = front()
        self.back = back()
    }

    var body: some View {
        ZStack {
            // BACK
            background
                .overlay(back)
                .opacity(isFlipped ? 1 : 0)
                .rotation3DEffect(
                    .degrees(isFlipped ? 0 : -180),
                    axis: (x: 0, y: 1, z: 0)
                )

            // FRONT
            background
                .overlay(front)
                .opacity(isFlipped ? 0 : 1)
                .rotation3DEffect(
                    .degrees(isFlipped ? 180 : 0),
                    axis: (x: 0, y: 1, z: 0)
                )
        }
        .frame(width: width)
        .frame(height: height * 0.9)
        .padding(.horizontal, 24)
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: isFlipped)
    }
}

