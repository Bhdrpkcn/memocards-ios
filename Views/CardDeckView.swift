import SwiftUI

struct CardDeckView: View {

    let deck: Deck
    let filter: CardSessionFilter
    let userId: Int

    @StateObject private var vm: CardDeckViewModel

    @State private var isFlipped = false
    @State private var dragOffset: CGSize = .zero

    init(deck: Deck, filter: CardSessionFilter, userId: Int) {
        self.deck = deck
        self.filter = filter
        self.userId = userId
        _vm = StateObject(
            wrappedValue: CardDeckViewModel(
                deck: deck,
                filter: filter,
                userId: userId
            )
        )
    }

    var body: some View {
        GeometryReader { geo in
            let cardAreaHeight = geo.size.height * 0.70

            VStack(spacing: 16) {

                Spacer()

                // MARK: - Deck header
                VStack(spacing: 4) {
                    Text(deck.name)
                        .font(.title2.bold())
                    if let description = deck.description {
                        Text(description)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                }
                .padding(.top, 12)

                Divider()

                // MARK: - Body
                ZStack {
                    if vm.isLoading {
                        ProgressView("Loading cards…")
                    } else if let top = vm.topCard {
                        cardStack(topCard: top, height: cardAreaHeight)
                    } else {
                        VStack(spacing: 12) {
                            Text("No more cards 🎉")
                                .font(.title3.bold())
                            Text("You’ve finished this deck.")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: cardAreaHeight)

                Spacer()

                Text("Swipe right = know, left = review, down = save to your deck")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.bottom, 8)
                    .multilineTextAlignment(.center)
                    .allowsHitTesting(false)
            }
            .padding(.horizontal)
            .task {
                await vm.loadCards()
            }
        }
    }

    // MARK: - Card stack
    private func cardStack(topCard: MemoCard, height: CGFloat) -> some View {
        ZStack {
            if let second = vm.secondCard {
                CardView(card: second, isFlipped: false, height: height)
                    .scaleEffect(0.96)
                    .offset(y: 14)
                    .rotationEffect(.degrees(-6))
                    .opacity(0.9)
                    .allowsHitTesting(false)
            }

            if let third = vm.thirdCard {
                CardView(card: third, isFlipped: false, height: height)
                    .scaleEffect(0.92)
                    .offset(y: 28)
                    .rotationEffect(.degrees(6))
                    .opacity(0.8)
                    .allowsHitTesting(false)
            }

            // TOP interactive card
            CardView(card: topCard, isFlipped: isFlipped, height: height)
                .offset(dragOffset)
                .rotationEffect(.degrees(Double(dragOffset.width / 15)))
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            dragOffset = value.translation
                        }
                        .onEnded { value in
                            handleDragEnd(translation: value.translation)
                        }
                )
                .onTapGesture {
                    withAnimation {
                        isFlipped.toggle()
                    }
                }
                .animation(.spring(), value: dragOffset)

                // MARK: Swipe feedback overlays
                .overlay(alignment: .topTrailing) {
                    if dragOffset.width > 0 {
                        swipeLabel(text: "I understand", color: .green, alignment: .trailing)
                            .opacity(min(Double(dragOffset.width / 120), 1.0))
                            .padding(.top, 24)
                            .padding(.trailing, 24)
                    }
                }
                .overlay(alignment: .topLeading) {
                    if dragOffset.width < 0 {
                        swipeLabel(text: "Review later", color: .red, alignment: .leading)
                            .opacity(min(Double(-dragOffset.width / 120), 1.0))
                            .padding(.top, 24)
                            .padding(.leading, 24)
                    }
                }
                .overlay(alignment: .bottom) {
                    if dragOffset.height > 0 {
                        swipeLabel(text: "Save to My Deck", color: .blue, alignment: .center)
                            .opacity(min(Double(dragOffset.height / 120), 1.0))
                            .padding(.bottom, 24)
                    }
                }
        }
    }

    // MARK: - Drag resolution
    private func handleDragEnd(translation: CGSize) {
        let horizontal = translation.width
        let vertical = translation.height
        let threshold: CGFloat = 100

        if abs(vertical) > abs(horizontal), vertical > threshold {
            handleSwipeDown()
        } else if horizontal > threshold {
            handleSwipeRight()
        } else if horizontal < -threshold {
            handleSwipeLeft()
        } else {
            withAnimation(.spring()) {
                dragOffset = .zero
            }
        }
    }

    private func handleSwipeRight() {
        guard let card = vm.topCard else {
            dragOffset = .zero
            return
        }

        withAnimation(.spring()) {
            dragOffset = CGSize(width: 500, height: 0)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            isFlipped = false
            dragOffset = .zero
            vm.markKnown(card)
        }
    }

    private func handleSwipeLeft() {
        guard let card = vm.topCard else {
            dragOffset = .zero
            return
        }

        withAnimation(.spring()) {
            dragOffset = CGSize(width: -500, height: 0)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            isFlipped = false
            dragOffset = .zero
            vm.markReview(card)
        }
    }

    private func handleSwipeDown() {
        guard let card = vm.topCard else {
            dragOffset = .zero
            return
        }

        withAnimation(.spring()) {
            dragOffset = CGSize(width: 0, height: 500)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            isFlipped = false
            dragOffset = .zero
            vm.storeCard(card)
        }
    }

    // MARK: - Swipe label helper
    private func swipeLabel(text: String, color: Color, alignment: HorizontalAlignment) -> some View
    {
        Text(text)
            .font(.title2.bold())
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(color, lineWidth: 2)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.white.opacity(0.85))
                    )
            )
            .foregroundColor(color)
            .rotationEffect(rotationAngle(for: alignment))
    }

    private func rotationAngle(for alignment: HorizontalAlignment) -> Angle {
        switch alignment {
        case .leading:
            return .degrees(-12)
        case .trailing:
            return .degrees(12)
        default:
            return .degrees(0)
        }
    }
}
