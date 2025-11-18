import Foundation

final class DeckService {

    func fetchDecks() async throws -> [Deck] {
        let dtos = try await APIConfig.client.request([DeckSummaryDTO].self, APIEndpoints.decks())
        return dtos.map(Deck.init(from:))
    }

    func fetchDeckDetail(id: Int) async throws -> Deck {
        let dto = try await APIConfig.client.request(DeckDetailDTO.self, APIEndpoints.deck(id))
        return Deck(from: dto)
    }
}
