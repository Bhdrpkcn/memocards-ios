import Foundation

struct DeckSummaryDTO: Decodable {
    let id: Int
    let name: String
    let description: String?
    let fromLanguageCode: String
    let toLanguageCode: String
    let isPublic: Bool
    let cardCount: Int
}

struct DeckDetailDTO: Decodable {
    let id: Int
    let name: String
    let description: String?
    let fromLanguageCode: String
    let toLanguageCode: String
    let isPublic: Bool
    let cardCount: Int
    let createdAt: Date
    let updatedAt: Date
}
