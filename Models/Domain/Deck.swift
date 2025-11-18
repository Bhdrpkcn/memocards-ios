import Foundation

struct Deck: Identifiable, Equatable, Hashable {
    let id: Int
    let name: String
    let description: String?
    let fromLanguageCode: String
    let toLanguageCode: String
    let isPublic: Bool
    let cardCount: Int

    // MARK: - Mappers
    init(from dto: DeckSummaryDTO) {
        self.id = dto.id
        self.name = dto.name
        self.description = dto.description
        self.fromLanguageCode = dto.fromLanguageCode
        self.toLanguageCode = dto.toLanguageCode
        self.isPublic = dto.isPublic
        self.cardCount = dto.cardCount
    }

    init(from detail: DeckDetailDTO) {
        self.id = detail.id
        self.name = detail.name
        self.description = detail.description
        self.fromLanguageCode = detail.fromLanguageCode
        self.toLanguageCode = detail.toLanguageCode
        self.isPublic = detail.isPublic
        self.cardCount = detail.cardCount
    }
}
