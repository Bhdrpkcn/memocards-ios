import SwiftUI

struct FlipCard<Front: View, Back: View>: View {

    @Binding var isFlipped: Bool
    let width: CGFloat
    let height: CGFloat
    let front: Front
    let back: Back

    var body: some View {
        ZStack {
            front
                .opacity(isFlipped ? 0 : 1)
                .rotation3DEffect(
                    .degrees(isFlipped ? 180 : 0),
                    axis: (0, 1, 0)
                )

            back
                .opacity(isFlipped ? 1 : 0)
                .rotation3DEffect(
                    .degrees(isFlipped ? 0 : -180),
                    axis: (0, 1, 0)
                )
        }
        .frame(width: width, height: height)
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.smooth(duration: 0.4)) {
                isFlipped.toggle()
            }
            Task { @MainActor in
                HapticsService.shared.flip()
            }
        }
    }
}
