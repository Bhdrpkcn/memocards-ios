import Foundation

protocol DeckServiceProtocol {
    func fetchDecks(
        from fromLanguageCode: String,
        to toLanguageCode: String,
        difficulty: CardDifficulty?
    ) async throws -> [Deck]
}

final class DeckService: DeckServiceProtocol {

    func fetchDecks(
        from fromLanguageCode: String,
        to toLanguageCode: String,
        difficulty: CardDifficulty? = nil
    ) async throws -> [Deck] {
        let path = APIEndpoints.wordSets(
            from: fromLanguageCode,
            to: toLanguageCode,
            difficulty: difficulty
        )

        let dtos = try await APIConfig.client.request([WordSetDTO].self, path)
        let pair = LanguagePair(fromCode: fromLanguageCode, toCode: toLanguageCode)

        return dtos.map { DeckMapper.map(dto: $0, pair: pair) }
    }
}
