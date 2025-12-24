struct Deck: Identifiable, Equatable, Hashable {
    let id: Int
    let name: String
    let description: String?

    let fromLanguageCode: String
    let toLanguageCode: String

    let difficulty: CardDifficulty?
    let isCustom: Bool
    let cardCount: Int?

    init(
        id: Int,
        name: String,
        description: String? = nil,
        fromLanguageCode: String,
        toLanguageCode: String,
        difficulty: CardDifficulty? = nil,
        isCustom: Bool,
        cardCount: Int? = nil
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.fromLanguageCode = fromLanguageCode
        self.toLanguageCode = toLanguageCode
        self.difficulty = difficulty
        self.isCustom = isCustom
        self.cardCount = cardCount
    }
}
