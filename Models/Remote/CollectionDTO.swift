import Foundation

enum CollectionScope: String, Codable {
    case LANGUAGE
    case GLOBAL
}

struct CollectionDTO: Decodable {
    let id: Int
    let name: String
    let scope: CollectionScope
    let languageCode: String?
    let wordCount: Int?
}

struct CollectionWordsResponseDTO: Decodable {
    let collectionId: Int
    let name: String
    let fromLanguage: String
    let toLanguage: String
    let words: [WordItemDTO]
}
