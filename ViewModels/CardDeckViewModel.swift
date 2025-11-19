import Foundation

@MainActor
final class CardDeckViewModel: ObservableObject {

    @Published var cards: [MemoCard] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    let deck: Deck
    private let cardService: CardService

    init(deck: Deck, cardService: CardService = CardService()) {
        self.deck = deck
        self.cardService = cardService
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
            let fetched = try await cardService.fetchCards(deckId: deck.id)
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

    // MARK: - Swipe intents

    func markKnown(_ card: MemoCard) {
        // TODO: hook to backend: statusKind = .known
    }

    func markReview(_ card: MemoCard) {
        // TODO: hook to backend: statusKind = .review
    }

    func storeCard(_ card: MemoCard) {
        // TODO: hook to backend or local storage:
    }
}
