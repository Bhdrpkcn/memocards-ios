import Foundation

@MainActor
final class CardDeckViewModel: ObservableObject {
    @Published var cards: [MemoCard] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    @Published var customDecks: [Deck] = []
    @Published var isLoadingCustomDecks = false
    @Published var customDeckError: String?

    let deck: Deck
    let filter: CardSessionFilter

    private let cardService: CardService
    private let progressService: ProgressService
    private let customDeckService: CustomDeckService
    private let userId: Int

    init(
        deck: Deck,
        filter: CardSessionFilter,
        userId: Int,
        cardService: CardService = CardService(),
        customDeckService: CustomDeckService = CustomDeckService()
    ) {
        self.deck = deck
        self.filter = filter
        self.userId = userId
        self.cardService = cardService
        self.progressService = ProgressService(userId: userId)
        self.customDeckService = customDeckService
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

    // MARK: - Custom decks
    func loadCustomDecksIfNeeded() async {
        // Only relevant when browsing a base deck; for custom decks we can skip
        if deck.isCustom { return }

        isLoadingCustomDecks = true
        customDeckError = nil

        do {
            let decks = try await customDeckService.fetchCustomDecks(
                parentDeckId: deck.id,
                userId: userId
            )
            self.customDecks = decks
        } catch {
            self.customDeckError = error.localizedDescription
        }

        isLoadingCustomDecks = false
    }

    func addCard(_ card: MemoCard, to customDeck: Deck) async throws {
        try await customDeckService.addCard(
            to: customDeck.id,
            from: card.id,
            userId: userId
        )
        removeCard(card)
    }

    func createCustomDeckAndAddCard(
        name: String,
        card: MemoCard
    ) async throws {
        let deck = try await customDeckService.createCustomDeck(
            parentDeckId: self.deck.id,
            userId: userId,
            name: name
        )

        // Update local list so UI sees the new deck
        customDecks.append(deck)

        try await customDeckService.addCard(
            to: deck.id,
            from: card.id,
            userId: userId
        )
        removeCard(card)
    }

    func deleteCustomDeck(_ deck: Deck) async throws {
        try await customDeckService.deleteCustomDeck(
            customDeckId: deck.id,
            userId: userId
        )
        customDecks.removeAll { $0.id == deck.id }
    }

    // MARK: - Swipe actions
    func removeCard(_ card: MemoCard) {
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
            //TODO: will be turned into save to a custom deck
            //            try? await progressService.updateStatus(cardId: card.id, status: .custom)
        }
    }
}
