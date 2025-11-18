import Foundation

enum APIEndpoints {
    static func decks() -> String { "decks" }
    static func deck(_ id: Int) -> String { "decks/\(id)" }
    static func cards(_ deckId: Int) -> String { "decks/\(deckId)/cards" }
}
