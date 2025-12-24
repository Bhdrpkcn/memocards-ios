import Foundation

struct EmptyDTO: Decodable {}

protocol CollectionsServiceProtocol {
    func fetchCollections(userId: Int, fromLanguageCode: String, toLanguageCode: String)
        async throws -> [Deck]
    func createCollection(
        userId: Int,
        fromLanguageCode: String,
        toLanguageCode: String,
        name: String
    ) async throws -> Deck
    func addCollectionItem(to collectionId: Int, wordId: Int, userId: Int) async throws
    func deleteCollection(collectionId: Int, userId: Int) async throws
}

final class CollectionsService: CollectionsServiceProtocol {

    func fetchCollections(userId: Int, fromLanguageCode: String, toLanguageCode: String)
        async throws -> [Deck]
    {

        let path = APIEndpoints.collections(userId: userId, scope: .LANGUAGE)
        let dtos = try await APIConfig.client.request([CollectionDTO].self, path)
        let filtered = dtos.filter { $0.languageCode == toLanguageCode }
        return filtered.map {
            DeckMapper.map(
                dto: $0,
                fromLanguageCode: fromLanguageCode,
                toLanguageCode: toLanguageCode
            )
        }
    }

    func createCollection(
        userId: Int,
        fromLanguageCode: String,
        toLanguageCode: String,
        name: String
    ) async throws -> Deck {

        struct Body: Encodable {
            let userId: Int
            let name: String
            let scope: CollectionScope
            let languageCode: String
        }
        let path = "collections"
        let dto = try await APIConfig.client.request(
            CollectionDTO.self,
            path,
            method: .POST,
            body: Body(userId: userId, name: name, scope: .LANGUAGE, languageCode: toLanguageCode)
        )
        return DeckMapper.map(
            dto: dto,
            fromLanguageCode: fromLanguageCode,
            toLanguageCode: toLanguageCode
        )
    }

    func addCollectionItem(to collectionId: Int, wordId: Int, userId: Int) async throws {

        struct Body: Encodable {
            let userId: Int
            let wordId: Int
        }
        let path = APIEndpoints.collectionItems(collectionId: collectionId)
        _ = try await APIConfig.client.request(
            EmptyDTO.self,
            path,
            method: .POST,
            body: Body(userId: userId, wordId: wordId)
        )
    }

    func deleteCollection(collectionId: Int, userId: Int) async throws {
        let path = APIEndpoints.collection(collectionId: collectionId, userId: userId)
        _ = try await APIConfig.client.request(EmptyDTO.self, path, method: .DELETE)
    }
}
