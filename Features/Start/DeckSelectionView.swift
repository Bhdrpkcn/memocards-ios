import SwiftUI

struct DeckSelectionView: View {

    let easyDecks: [Deck]
    let mediumDecks: [Deck]
    let hardDecks: [Deck]
    let collections: [Deck]

    let errorMessage: String?
    let isLoading: Bool

    @Binding var selectedDeck: Deck?
    @Binding var selectedFilter: CardSessionFilter

    let onStart: () -> Void
    let onChangeLanguages: () -> Void

    // MARK: - UI State
    private enum DeckSource: String {
        case premade = "Premade"
        case user = "User's"
    }

    @State private var source: DeckSource = .premade
    @State private var currentIndex: Int = 0

    @State private var isFlipped: Bool = false
    @State private var dragOffset: CGSize = .zero

    var body: some View {
        VStack(spacing: 14) {

            if isLoading {
                ProgressView("Loading your decks...")
                    .padding(.top, 8)
            }

            sourceSelector

            GeometryReader { geo in
                let cardHeight: CGFloat = 220
                let cardWidth: CGFloat = min(geo.size.width * 0.75, 300)

                CardStack(
                    showSecond: secondDeck != nil,
                    showThird: thirdDeck != nil
                ) {
                    if let d = thirdDeck {
                        DeckCardView(deck: d, isFlipped: .constant(false), height: cardHeight, width: cardWidth)
                    }
                } second: {
                    if let d = secondDeck {
                        DeckCardView(deck: d, isFlipped: .constant(false), height: cardHeight, width: cardWidth)
                    }
                } top: {
                    if let d = currentDeck {
                        DeckCardView(deck: d, isFlipped: $isFlipped, height: cardHeight, width: cardWidth)
                            .offset(dragOffset)
                            .rotationEffect(.degrees(Double(dragOffset.width / 15)))
                            .gesture(
                                DragGesture()
                                    .onChanged { dragOffset = $0.translation }
                                    .onEnded { handleDeckDragEnd(translation: $0.translation) }
                            )
                            .onTapGesture { withAnimation { isFlipped.toggle() } }
                            .animation(.spring(), value: dragOffset)
                    } else {
                        emptyDeckState
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }
            .frame(height: 220)

            if let errorMessage, !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
            }

            filterRow

            Button(action: onStart) {
                Text("Start")
                    .font(.headline)
                    .padding(.vertical)
                    .padding(.horizontal, 60)
                    .background(selectedDeck == nil ? Color.gray : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(14)
                    
            }
            .disabled(selectedDeck == nil)
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 12)
        .onAppear { syncSelection() }
        .onChange(of: source) {
            resetBrowseState()
            syncSelection()
        }
        .onChange(of: currentDecks.count) {
            clampIndexAndSync()
        }
    }

    // MARK: - Data

    private var allPremadeDecks: [Deck] {
        easyDecks + mediumDecks + hardDecks
    }

    private var currentDecks: [Deck] {
        switch source {
        case .premade: return allPremadeDecks
        case .user: return collections
        }
    }

    private var currentDeck: Deck? {
        guard !currentDecks.isEmpty else { return nil }
        guard currentIndex >= 0, currentIndex < currentDecks.count else { return nil }
        return currentDecks[currentIndex]
    }

    private var secondDeck: Deck? {
        let idx = currentIndex + 1
        guard idx >= 0, idx < currentDecks.count else { return nil }
        return currentDecks[idx]
    }

    private var thirdDeck: Deck? {
        let idx = currentIndex + 2
        guard idx >= 0, idx < currentDecks.count else { return nil }
        return currentDecks[idx]
    }

    // MARK: - Source selector

    private var sourceSelector: some View {
        HStack(spacing: 8) {
            sourceButton(.premade)
            sourceButton(.user)
        }
        .padding(4)
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.horizontal, 12)
    }

    private func sourceButton(_ target: DeckSource) -> some View {
        Button {
            guard source != target else { return }
            source = target
        } label: {
            Text(target.rawValue)
                .font(.subheadline.weight(.semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(source == target ? Color.white : Color.clear)
                .cornerRadius(10)
                .foregroundColor(source == target ? .black : .secondary)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Empty

    private var emptyDeckState: some View {
        VStack(spacing: 8) {
            Text("No decks available")
                .font(.headline)
            Text("Try switching the source or changing languages.")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Filter row

    private var filterRow: some View {
        HStack(spacing: 22) {
            filterItem(icon: "circle.grid.3x3", label: "All", type: .all)
            filterItem(icon: "checkmark.seal.fill", label: "Known", type: .known)
            filterItem(icon: "arrow.triangle.2.circlepath", label: "Review", type: .review)
        }
        .padding(.top, 6)
    }

    private func filterItem(icon: String, label: String, type: CardSessionFilter) -> some View {
        Button {
            selectedFilter = type
        } label: {
            VStack {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .bold))
                Text(label)
                    .font(.caption2)
            }
            .foregroundColor(selectedFilter == type ? .blue : .gray)
            .padding(6)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Browsing swipe (no actions)

    private func handleDeckDragEnd(translation: CGSize) {
        let threshold: CGFloat = 80
        let horizontal = translation.width

        if horizontal > threshold {
            goToPreviousDeck()
        } else if horizontal < -threshold {
            goToNextDeck()
        } else {
            withAnimation(.spring()) {
                dragOffset = .zero
            }
        }
    }

    private func goToNextDeck() {
        guard !currentDecks.isEmpty else { return }
        let newIndex = min(currentIndex + 1, currentDecks.count - 1)
        animateToIndex(newIndex, direction: .left)
    }

    private func goToPreviousDeck() {
        guard !currentDecks.isEmpty else { return }
        let newIndex = max(currentIndex - 1, 0)
        animateToIndex(newIndex, direction: .right)
    }

    private enum SwipeDirection { case left, right }

    private func animateToIndex(_ index: Int, direction: SwipeDirection) {
        guard index != currentIndex else {
            withAnimation(.spring()) { dragOffset = .zero }
            return
        }

        // push out
        withAnimation(.spring()) {
            dragOffset = CGSize(width: direction == .left ? -420 : 420, height: 0)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
            currentIndex = index
            isFlipped = false
            dragOffset = .zero
            selectedDeck = currentDeck
        }
    }

    // MARK: - Sync helpers

    private func resetBrowseState() {
        currentIndex = 0
        isFlipped = false
        dragOffset = .zero
    }

    private func syncSelection() {
        guard !currentDecks.isEmpty else {
            selectedDeck = nil
            return
        }

        if let selectedDeck,
            let idx = currentDecks.firstIndex(of: selectedDeck)
        {
            currentIndex = idx
        } else {
            currentIndex = 0
            selectedDeck = currentDeck
        }
    }

    private func clampIndexAndSync() {
        guard !currentDecks.isEmpty else {
            selectedDeck = nil
            return
        }

        if currentIndex >= currentDecks.count {
            currentIndex = max(0, currentDecks.count - 1)
        }

        selectedDeck = currentDeck
    }
}
