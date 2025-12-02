import Foundation

struct Deck: Identifiable, Equatable, Hashable {
    let id: Int
    let name: String
    let description: String?

    let fromLanguageCode: String
    let toLanguageCode: String

    let difficulty: CardDifficulty?

    let isCustom: Bool

    let cardCount: Int?

    // MARK: - Mappers
    init(from dto: WordSetDTO, pair: LanguagePair) {
        self.id = dto.id
        self.name = dto.name
        self.description = dto.description
        self.fromLanguageCode = pair.fromCode
        self.toLanguageCode = pair.toCode
        self.difficulty = dto.difficulty
        self.isCustom = false
        self.cardCount = nil
    }

    init(from collection: CollectionDTO) {
        self.id = collection.id
        self.name = collection.name
        self.description = nil
        self.fromLanguageCode = ""  
        self.toLanguageCode = collection.languageCode ?? ""
        self.difficulty = nil
        self.isCustom = true
        self.cardCount = collection.itemCount
    }
}
