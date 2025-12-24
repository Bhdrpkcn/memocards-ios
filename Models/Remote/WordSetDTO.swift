import Foundation

struct WordSetDTO: Decodable {
    let id: Int
    let name: String
    let description: String?
    let difficulty: CardDifficulty
    let wordCount: Int?
}
