import Foundation

struct WordSetWordsResponseDTO: Decodable {
    let wordSetId: Int
    let name: String
    let difficulty: CardDifficulty
    let fromLanguage: String
    let toLanguage: String
    let words: [WordItemDTO]
}

struct WordItemDTO: Decodable {
    let wordId: Int
    let front: String
    let back: String
}
