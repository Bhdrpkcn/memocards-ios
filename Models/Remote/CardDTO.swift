import Foundation

struct CardDTO: Decodable {
    let id: Int
    let frontText: String
    let backText: String
    let difficulty: CardDifficulty? 
    let orderIndex: Int
}
