import SwiftUI

struct CardDeckView: View {

    let deck: Deck
    @StateObject private var vm: CardDeckViewModel

    @State private var isFlipped = false
    @State private var dragOffset: CGSize = .zero

    init(deck: Deck) {
        self.deck = deck
        _vm = StateObject(wrappedValue: CardDeckViewModel(deck: deck))
    }

    var body: some View {
        VStack(spacing: 16) {

            // MARK: - Header
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

            // MARK: - Body
            ZStack {
                if vm.isLoading {
                    ProgressView("Loading cards…")
                } else if let top = vm.topCard {
                    cardStack(topCard: top)
                } else {
                    VStack(spacing: 12) {
                        Text("No more cards 🎉")
                            .font(.title3.bold())
                        Text("You’ve finished this deck.")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .padding(.horizontal)
        .task {
            await vm.loadCards()
        }
    }

    // MARK: - Card stack with background deck styling
    private func cardStack(topCard: MemoCard) -> some View {
        ZStack {
            if let second = vm.secondCard {
                CardView(card: second, isFlipped: false)
                    .scaleEffect(0.96)
                    .offset(y: 14)
                    .rotationEffect(.degrees(-4))
                    .opacity(0.9)
                    .allowsHitTesting(false)
            }
            if let third = vm.thirdCard {
                CardView(card: third, isFlipped: false)
                    .scaleEffect(0.92)
                    .offset(y: 28)
                    .rotationEffect(.degrees(4))
                    .opacity(0.8)
                    .allowsHitTesting(false)
            }

            // TOP interactive card
            CardView(card: topCard, isFlipped: isFlipped)
                .offset(dragOffset)
                .rotationEffect(.degrees(Double(dragOffset.width / 15)))
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            dragOffset = value.translation
                        }
                        .onEnded { value in
                            let threshold: CGFloat = 100
                            if value.translation.width > threshold {
                                handleSwipeRight()
                            } else if value.translation.width < -threshold {
                                handleSwipeLeft()
                            } else {
                                withAnimation(.spring()) {
                                    dragOffset = .zero
                                }
                            }
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
                        swipeLabel(text: "I don’t get it", color: .red, alignment: .leading)
                            .opacity(min(Double(-dragOffset.width / 120), 1.0))
                            .padding(.top, 24)
                            .padding(.leading, 24)
                    }
                }
        }
    }

    private func handleSwipeRight() {
        withAnimation(.spring()) {
            dragOffset = CGSize(width: 500, height: 0)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            isFlipped = false
            dragOffset = .zero
            vm.removeTopCard()
        }
    }

    private func handleSwipeLeft() {
        withAnimation(.spring()) {
            dragOffset = CGSize(width: -500, height: 0)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            isFlipped = false
            dragOffset = .zero
            vm.removeTopCard()
        }
    }

    @ViewBuilder
    private func swipeLabel(text: String, color: Color, alignment: HorizontalAlignment) -> some View
    {
        Text(text)
            .font(.headline.bold())
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(color.opacity(0.2))
            .foregroundColor(color)
            .clipShape(Capsule())
    }
}
