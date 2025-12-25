import Foundation

struct DeckMapper {

    static func map(dto: WordSetDTO, pair: LanguagePair) -> Deck {
        Deck(
            id: dto.id,
            name: dto.name,
            description: dto.description,
            fromLanguageCode: pair.fromCode,
            toLanguageCode: pair.toCode,
            difficulty: dto.difficulty,
            isCustom: false,
            cardCount: dto.wordCount
        )
    }

    static func map(
        dto: CollectionDTO,
        fromLanguageCode: String,
        toLanguageCode: String
    ) -> Deck {
        Deck(
            id: dto.id,
            name: dto.name,
            description: nil,
            fromLanguageCode: fromLanguageCode,
            toLanguageCode: toLanguageCode,
            difficulty: nil,
            isCustom: true,
            cardCount: dto.wordCount
        )
    }
}
