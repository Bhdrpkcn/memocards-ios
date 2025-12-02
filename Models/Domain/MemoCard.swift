import SwiftUI

struct MemoCard: Identifiable, Equatable {
    let id: Int
    let frontText: String
    let backText: String
    let difficulty: CardDifficulty?
    let orderIndex: Int

    let color: Color
}
