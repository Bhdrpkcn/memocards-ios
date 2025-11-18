import Foundation

protocol DecksServiceProtocol {
    func loadAvailableDecks() -> [Deck]
    func defaultDeck() -> Deck
}

final class StaticDecksService: DecksServiceProtocol {

    private let decks: [Deck] = [
        Deck(
            id: "default",
            name: "Basic Vocabulary",
            resourceName: "cards",
            description: "Core words you want to memorize first."
        )
    ]

    func loadAvailableDecks() -> [Deck] {
        decks
    }

    func defaultDeck() -> Deck {
        decks.first!
    }
}
