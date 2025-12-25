import SwiftUI

struct CardDeckView: View {
    // MARK: - Inputs
    let deck: Deck
    let filter: CardSessionFilter
    let userId: Int

    @StateObject private var vm: CardDeckViewModel

    // MARK: - Orchestrator State
    @State private var pendingCardToSave: MemoCard?
    @State private var showDeckChoiceOverlay = false
    @State private var showSaveSheet = false

    init(deck: Deck, filter: CardSessionFilter, userId: Int) {
        self.deck = deck
        self.filter = filter
        self.userId = userId
        _vm = StateObject(
            wrappedValue: CardDeckViewModel(deck: deck, filter: filter, userId: userId)
        )
    }

    var body: some View {
        GeometryReader { geo in
            let cardHeight = geo.size.height * 0.70

            ZStack {
                VStack(spacing: 16) {
                    Spacer()

                    // Header
                    DeckHeaderView(deck: deck, count: vm.cards.count, filter: filter)

                    Divider().overlay(AppTheme.Colors.textSecondary.opacity(0.3))

                    // CardStack
                    ZStack {
                        if vm.isLoading {
                            ProgressView("Loading cards…")
                        } else if vm.cards.isEmpty {
                            EmptyFinishedView()
                        } else {
                            InteractiveCardStack(
                                topCard: vm.topCard,
                                secondCard: vm.secondCard,
                                thirdCard: vm.thirdCard,
                                height: cardHeight,
                                onSwipeRight: { vm.markKnown($0) },
                                onSwipeLeft: { vm.markReview($0) },
                                onSwipeDown: { card in
                                    pendingCardToSave = card
                                    showDeckChoiceOverlay = true
                                }
                            )
                        }
                    }
                    .frame(height: cardHeight)
                    .frame(maxWidth: .infinity)

                    Spacer()

                    // Footer
                    Text("Swipe right = know, left = review, down = save")
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                        .padding(.bottom, 8)
                }
                .padding(.horizontal)

                // Overlays
                if showDeckChoiceOverlay {
                    DeckChoiceOverlay(
                        onSave: {
                            showDeckChoiceOverlay = false
                            showSaveSheet = true
                        },
                        onCancel: {
                            showDeckChoiceOverlay = false
                            pendingCardToSave = nil
                        }
                    )
                    .zIndex(2)
                }
            }
            // Lifecycle
            .task { await vm.loadCards() }
            .sheet(isPresented: $showSaveSheet) {
                SaveToCollectionSheet(
                    vm: vm,
                    pendingCard: $pendingCardToSave,
                    isPresented: $showSaveSheet
                )
                .presentationDetents([.medium, .large])
            }
        }
    }
}

// MARK: Subcomponents

private struct DeckHeaderView: View {
    let deck: Deck
    let count: Int
    let filter: CardSessionFilter

    var body: some View {
        VStack(spacing: 4) {
            Text(deck.name)
                .font(.title2.bold())
                .foregroundColor(AppTheme.Colors.textPrimary)

            if let desc = deck.description {
                Text(desc)
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.Colors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            Text(sessionText)
                .font(.caption)
                .foregroundStyle(AppTheme.Colors.textSecondary)
        }
        .padding(.top, 12)
    }

    var sessionText: String {
        let base = count == 1 ? "1 card" : "\(count) cards"
        return "\(base) · \(filter.rawValue.capitalized)"
    }
}

private struct EmptyFinishedView: View {
    var body: some View {
        VStack(spacing: 12) {
            Text("No more cards 🎉")
                .font(.title3.bold())
                .foregroundColor(AppTheme.Colors.textPrimary)
            Text("You’ve finished this deck.")
                .foregroundStyle(AppTheme.Colors.textSecondary)
        }
    }
}

private struct DeckChoiceOverlay: View {
    let onSave: () -> Void
    let onCancel: () -> Void

    var body: some View {
        ZStack {
            AppTheme.Colors.overlayBackground
                .ignoresSafeArea()
                .onTapGesture { onCancel() }

            VStack(spacing: 20) {
                VStack(spacing: 8) {
                    Text("Keep this word?")
                        .font(.headline)
                    Text("Save it to one of your collections.")
                        .font(.caption)
                        .foregroundColor(AppTheme.Colors.textSecondary)
                }

                Button {
                    onSave()
                } label: {
                    Text("Save to Collection")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppTheme.Colors.progress)
                        .foregroundColor(AppTheme.Colors.textPrimary)
                        .cornerRadius(14)
                }

                Button {
                    onCancel()
                } label: {
                    Text("Cancel")
                        .font(.headline)
                        .foregroundColor(AppTheme.Colors.error)
                }
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(AppTheme.Colors.screenSecBackground)
            )
            .padding(.horizontal, 40)
        }
        .transition(.opacity)
    }
}
