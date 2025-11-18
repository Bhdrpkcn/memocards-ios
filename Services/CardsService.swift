import SwiftUI
import Foundation

final class CardService {

    func fetchCards(deckId: Int) async throws -> [MemoCard] {
        let dtos = try await APIConfig.client.request([CardDTO].self, APIEndpoints.cards(deckId))

        return dtos.enumerated().map { idx, dto in
            MemoCard(from: dto, color: colorForIndex(idx))
        }
    }

    private func colorForIndex(_ index: Int) -> Color {
        let palette: [Color] = [.blue, .green, .purple, .orange, .pink]
        return palette[index % palette.count]
    }
}
