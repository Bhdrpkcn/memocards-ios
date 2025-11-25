import Foundation

struct EmptyDTO: Decodable {}

final class CustomDeckService {

    func fetchCustomDecks(
        parentDeckId: Int,
        userId: Int
    ) async throws -> [Deck] {
        let path = "decks/\(parentDeckId)/custom-decks?userId=\(userId)"
        let dtos = try await APIConfig.client.request([DeckSummaryDTO].self, path)
        return dtos.map(Deck.init(from:))
    }

    func createCustomDeck(
        parentDeckId: Int,
        userId: Int,
        name: String
    ) async throws -> Deck {
        struct Body: Encodable {
            let userId: Int
            let name: String
        }

        let path = "decks/\(parentDeckId)/custom-decks"
        let dto = try await APIConfig.client.request(
            DeckDetailDTO.self,
            path,
            method: .POST,
            body: Body(userId: userId, name: name)
        )
        return Deck(from: dto)
    }

    func addCard(
        to customDeckId: Int,
        from sourceCardId: Int,
        userId: Int
    ) async throws {
        struct Body: Encodable {
            let userId: Int
            let sourceCardId: Int
        }

        let path = "decks/custom-decks/\(customDeckId)/cards"
        _ = try await APIConfig.client.request(
            EmptyDTO.self,
            path,
            method: .POST,
            body: Body(userId: userId, sourceCardId: sourceCardId)
        )
    }

    func deleteCustomDeck(
        customDeckId: Int,
        userId: Int
    ) async throws {
        let path = "decks/custom-decks/\(customDeckId)?userId=\(userId)"
        _ = try await APIConfig.client.request(
            EmptyDTO.self,
            path,
            method: .DELETE
        )
    }

    func removeCard(
        from customDeckId: Int,
        cardId: Int,
        userId: Int
    ) async throws {
        let path = "decks/custom-decks/\(customDeckId)/cards/\(cardId)?userId=\(userId)"
        _ = try await APIConfig.client.request(
            EmptyDTO.self,
            path,
            method: .DELETE
        )
    }
}
