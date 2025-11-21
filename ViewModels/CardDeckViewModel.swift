import Foundation

@MainActor
final class CardDeckViewModel: ObservableObject {
    @Published var cards: [MemoCard] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    let deck: Deck
    let filter: CardSessionFilter

    private let cardService: CardService
    private let progressService: ProgressService
    private let userId: Int

    init(
        deck: Deck,
        filter: CardSessionFilter,
        userId: Int,
        cardService: CardService = CardService()
    ) {
        self.deck = deck
        self.filter = filter
        self.userId = userId
        self.cardService = cardService
        self.progressService = ProgressService(userId: userId)
    }

    var topCard: MemoCard? {
        cards.last
    }

    var secondCard: MemoCard? {
        guard cards.count >= 2 else { return nil }
        return cards.dropLast().last
    }

    var thirdCard: MemoCard? {
        guard cards.count >= 3 else { return nil }
        return cards.dropLast(2).last
    }

    var isFinished: Bool {
        !isLoading && cards.isEmpty
    }

    func loadCards() async {
        isLoading = true
        errorMessage = nil

        do {
            let fetched = try await cardService.fetchCards(
                deckId: deck.id,
                filter: filter,
                userId: userId
            )
            self.cards = fetched
        } catch {
            self.errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func removeTopCard() {
        guard !cards.isEmpty else { return }
        cards.removeLast()
    }

    // MARK: - Swipe actions

    private func removeCard(_ card: MemoCard) {
        cards.removeAll { $0.id == card.id }
    }

    func markKnown(_ card: MemoCard) {
        removeCard(card)
        Task {
            try? await progressService.updateStatus(cardId: card.id, status: .known)
        }
    }

    func markReview(_ card: MemoCard) {
        removeCard(card)
        Task {
            try? await progressService.updateStatus(cardId: card.id, status: .review)
        }
    }

    func storeCard(_ card: MemoCard) {
        removeCard(card)
        Task {
            try? await progressService.updateStatus(cardId: card.id, status: .custom)
        }
    }
}
