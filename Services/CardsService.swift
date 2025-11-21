import Foundation
import SwiftUI

final class CardService {

    func fetchCards(
        deckId: Int,
        filter: CardSessionFilter,
        userId: Int
    ) async throws -> [MemoCard] {

        var path = "decks/\(deckId)/cards"
        var queryItems: [String] = []

        if let status = filter.backendStatusParam {
            queryItems.append("userId=\(userId)")
            queryItems.append("status=\(status)")
        }

        if !queryItems.isEmpty {
            path += "?" + queryItems.joined(separator: "&")
        }

        let dtos = try await APIConfig.client.request([CardDTO].self, path)

        return dtos.enumerated().map { idx, dto in
            MemoCard(from: dto, color: colorForIndex(idx))
        }
    }

    private func colorForIndex(_ index: Int) -> Color {
        let palette: [Color] = [.blue, .green, .purple, .orange, .pink]
        return palette[index % palette.count]
    }
}
