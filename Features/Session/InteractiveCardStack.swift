import SwiftUI

struct InteractiveCardStack: View {
    // Data Inputs
    let topCard: MemoCard?
    let secondCard: MemoCard?
    let thirdCard: MemoCard?
    let height: CGFloat

    // Actions (Callbacks)
    let onSwipeRight: (MemoCard) -> Void
    let onSwipeLeft: (MemoCard) -> Void
    let onSwipeDown: (MemoCard) -> Void

    // Internal Gesture State
    @State private var dragOffset: CGSize = .zero
    @State private var isFlipped = false

    var body: some View {
        CardStack(
            showSecond: secondCard != nil,
            showThird: thirdCard != nil
        ) {
            if let third = thirdCard {
                WordCardView(card: third, isFlipped: .constant(false), height: height)
            }
        } second: {
            if let second = secondCard {
                WordCardView(card: second, isFlipped: .constant(false), height: height)
            }
        } top: {
            if let top = topCard {
                WordCardView(card: top, isFlipped: $isFlipped, height: height)
                    .offset(dragOffset)
                    .rotationEffect(.degrees(Double(dragOffset.width / 15)))
                    .animation(.spring(), value: dragOffset)
                    .gesture(
                        DragGesture()
                            .onChanged { dragOffset = $0.translation }
                            .onEnded { handleDragEnd($0.translation, card: top) }
                    )
                    .onTapGesture { withAnimation { isFlipped.toggle() } }
                    // Overlays
                    .overlay(alignment: .topTrailing) {
                        swipeOverlay(
                            text: "Know",
                            color: AppTheme.Colors.success,
                            visible: dragOffset.width > 0,
                            opacity: dragOffset.width / 120
                        )
                    }
                    .overlay(alignment: .topLeading) {
                        swipeOverlay(
                            text: "Review",
                            color: AppTheme.Colors.error,
                            visible: dragOffset.width < 0,
                            opacity: -dragOffset.width / 120
                        )
                    }
                    .overlay(alignment: .bottom) {
                        swipeOverlay(
                            text: "Save",
                            color: AppTheme.Colors.progress,
                            visible: dragOffset.height > 0,
                            opacity: dragOffset.height / 120
                        )
                    }
            } else {
                Color.clear
            }
        }
    }

    // MARK: - Gesture Logic
    private func handleDragEnd(_ translation: CGSize, card: MemoCard) {
        let h = translation.width
        let v = translation.height
        let threshold: CGFloat = 100

        if abs(v) > abs(h) && v > threshold {
            // Down
            animateAndTrigger(offset: CGSize(width: 0, height: 500)) { onSwipeDown(card) }
        } else if h > threshold {
            // Right
            animateAndTrigger(offset: CGSize(width: 500, height: 0)) { onSwipeRight(card) }
        } else if h < -threshold {
            // Left
            animateAndTrigger(offset: CGSize(width: -500, height: 0)) { onSwipeLeft(card) }
        } else {
            // Reset
            withAnimation(.spring()) { dragOffset = .zero }
        }
    }

    private func animateAndTrigger(offset: CGSize, action: @escaping () -> Void) {
        withAnimation(.spring()) { dragOffset = offset }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            action()
            // Reset state for the NEXT card that comes to top
            dragOffset = .zero
            isFlipped = false
        }
    }

    private func swipeOverlay(text: String, color: Color, visible: Bool, opacity: Double)
        -> some View
    {
        Group {
            if visible {
                Text(text)
                    .font(.title2.bold())
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(AppTheme.Colors.screenBackground.opacity(0.9))
                            .shadow(radius: 5)
                    )
                    .foregroundColor(color)
                    .padding(24)
                    .opacity(min(opacity, 1.0))
            }
        }
    }
}
