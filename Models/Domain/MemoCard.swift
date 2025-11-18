import SwiftUI

struct MemoCard: Identifiable, Equatable {
    let id: Int
    let frontText: String
    let backText: String
    let difficulty: CardDifficulty?
    let orderIndex: Int

    let color: Color
}

// MARK: - Mapper from CardDTO
extension MemoCard {
    init(from dto: CardDTO, color: Color) {
        self.id = dto.id
        self.frontText = dto.frontText
        self.backText = dto.backText
        self.difficulty = dto.difficulty
        self.orderIndex = dto.orderIndex
        self.color = color
    }
}
