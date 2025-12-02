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
    private let collectionsService: CollectionsService
    private let userId: Int

    init(
        deck: Deck,
        filter: CardSessionFilter,
        userId: Int,
        cardService: CardService = CardService(),
        collectionsService: CollectionsService = CollectionsService()
    ) {
        self.deck = deck
        self.filter = filter
        self.userId = userId
        self.cardService = cardService
        self.progressService = ProgressService(userId: userId)
        self.collectionsService = collectionsService
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
                wordSetId: deck.id,
                fromLanguageCode: deck.fromLanguageCode,
                toLanguageCode: deck.toLanguageCode
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
        if deck.isCustom { return }

        isLoadingCustomDecks = true
        customDeckError = nil

        do {
            let decks = try await collectionsService.fetchCollections(
                userId: userId,
                toLanguageCode: deck.toLanguageCode
            )
            self.customDecks = decks
        } catch {
            self.customDeckError = error.localizedDescription
        }

        isLoadingCustomDecks = false
    }

    func addCard(_ card: MemoCard, to customDeck: Deck) async throws {
        try await collectionsService.addCollectionItem(
            to: customDeck.id,
            wordId: card.id,
            userId: userId
        )
        removeCard(card)
    }

    func createCustomDeckAndAddCard(
        name: String,
        card: MemoCard
    ) async throws {
        let deck = try await collectionsService.createCollection(
            userId: userId,
            toLanguageCode: self.deck.toLanguageCode,
            name: name
        )

        customDecks.append(deck)

        try await collectionsService.addCollectionItem(
            to: deck.id,
            wordId: card.id,
            userId: userId
        )
        removeCard(card)
    }

    func deleteCustomDeck(_ deck: Deck) async throws {
        try await collectionsService.deleteCollection(
            collectionId: deck.id,
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
            try? await progressService.updateStatus(
                wordId: card.id,
                status: .known,
                fromLanguageCode: deck.fromLanguageCode,
                toLanguageCode: deck.toLanguageCode
            )
        }
    }

    func markReview(_ card: MemoCard) {
        removeCard(card)
        Task {
            try? await progressService.updateStatus(
                wordId: card.id,
                status: .review,
                fromLanguageCode: deck.fromLanguageCode,
                toLanguageCode: deck.toLanguageCode
            )
        }
    }
}
