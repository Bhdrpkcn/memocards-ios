import SwiftUI

@MainActor
struct CardsView: View {

    @StateObject private var viewModel: CardsViewModel
    @State private var dragOffset: CGSize = .zero
    @State private var isFlipped: Bool = false

    // MARK: - Inits
    init() {
        _viewModel = StateObject(wrappedValue: CardsViewModel())
    }

    init(viewModel: CardsViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    // MARK: - Body
    var body: some View {
        VStack(spacing: 16) {
            headerView

            ZStack {
                ForEach(viewModel.activeCards.indices, id: \.self) { index in
                    cardView(at: index)
                }
            }
        }
        .padding()
    }

    private var headerView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Memocards")
                        .font(.headline)

                    Text(
                        "Swipe right if you’ve memorized it, left if you need to see it again. Tap the card to see the translation."
                    )
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 8) {
                    progressRing

                    VStack(alignment: .trailing, spacing: 4) {
                        HStack {
                            Circle()
                                .frame(width: 6, height: 6)
                            Text("Known: \(viewModel.knownCount)")
                        }
                        .font(.caption2)

                        HStack {
                            Circle()
                                .frame(width: 6, height: 6)
                            Text("Review: \(viewModel.reviewCount)")
                        }
                        .font(.caption2)
                    }
                }
            }

            Picker("Filter", selection: $viewModel.filter) {
                ForEach(CardsFilter.allCases) { filter in
                    Text(filter.rawValue)
                        .tag(filter)
                }
            }
            .pickerStyle(.segmented)
        }
    }

    // MARK: Progress Ring
    private var progressRing: some View {
        let progress = viewModel.memorizationProgress

        return ZStack {
            Circle()
                .stroke(lineWidth: 4)
                .opacity(0.15)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    style: StrokeStyle(
                        lineWidth: 4,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut, value: progress)

            Text("\(Int(progress * 100))%")
                .font(.caption2)
                .monospacedDigit()
        }
        .frame(width: 40, height: 40)
    }

    // MARK: - Subviews
    private func cardView(at index: Int) -> some View {
        let visualIndex = viewModel.visualIndex(for: index)
        let isTopCard = (visualIndex == 0)

        let progress = min(
            abs(dragOffset.width) / viewModel.maxProgressDistance,
            1
        )

        let signedProgress = (dragOffset.width >= 0 ? 1 : -1) * progress

        let card = viewModel.activeCards[index]

        return FlipCard(
            isFlipped: Binding(
                get: { isTopCard ? isFlipped : false },
                set: { newValue in if isTopCard { isFlipped = newValue } }
            ),
            width: viewModel.cardWidth,
            height: 250,
            front:
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .foregroundStyle(card.color)

                    VStack(spacing: 8) {
                        Text(card.text)
                            .font(.title2)
                            .bold()
                    }
                    .padding()
                },
            back:
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .foregroundStyle(card.color)

                    VStack(spacing: 8) {
                        Text(card.textTranslate)
                            .font(.title2)
                            .bold()
                            .foregroundStyle(.white)
                    }
                    .padding()
                }
        )
        .frame(width: viewModel.cardWidth, height: 250)
        .offset(
            x: isTopCard ? dragOffset.width : Double(visualIndex) * 10,
            y: isTopCard ? 0 : Double(visualIndex) * -4
        )
        .zIndex(Double(viewModel.activeCards.count - visualIndex))
        .rotationEffect(
            .degrees(
                isTopCard
                    ? 0
                    : Double(visualIndex) * 3 - progress * 3
            ),
            anchor: .bottom
        )
        .scaleEffect(
            isTopCard
                ? 1.0
                : visualIndex == 1
                    ? (1.0 - Double(visualIndex) * 0.06 + progress * 0.06)
                    : (1.0 - Double(visualIndex) * 0.06)
        )
        .offset(x: isTopCard ? 0 : Double(visualIndex) * -3)
        .rotation3DEffect(
            .degrees(
                (isTopCard || visualIndex == 1)
                    ? 10 * signedProgress
                    : 0
            ),
            axis: (0, 1, 0)
        )
        .contentShape(Rectangle())
        .gesture(isTopCard ? dragGesture : nil)
    }

    // MARK: - Gestures
    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                dragOffset = value.translation
            }
            .onEnded { value in
                handleDragEnded(value)
            }
    }

    // MARK: - Interaction
    private func handleDragEnded(_ value: DragGesture.Value) {
        guard !viewModel.activeCards.isEmpty else {
            withAnimation { dragOffset = .zero }
            return
        }

        let direction: CGFloat = value.translation.width > 0 ? 1 : -1

        if abs(value.translation.width) > viewModel.swipeThreshold {
            let isRightSwipe = (direction > 0)
            let delay = direction < 0 ? 0.18 : 0.20

            withAnimation(.smooth(duration: 0.2)) {
                dragOffset.width =
                    isRightSwipe
                    ? viewModel.cardWidth * 1.33
                    : -viewModel.cardWidth
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(.smooth(duration: 0.5)) {
                    viewModel.registerSwipe(isRightSwipe ? .right : .left)
                    viewModel.advanceTopCard()
                    dragOffset = .zero
                    isFlipped = false
                }
            }
        } else {
            withAnimation {
                dragOffset = .zero
            }
        }
    }
}

#Preview {
    CardsView()
}
