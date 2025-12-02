import Foundation
import SwiftUI

final class CardService {

    func fetchCards(
        wordSetId: Int,
        fromLanguageCode: String,
        toLanguageCode: String
    ) async throws -> [MemoCard] {

        let path = APIEndpoints.wordSetWords(
            id: wordSetId,
            from: fromLanguageCode,
            to: toLanguageCode
        )

        let response = try await APIConfig.client.request(
            WordSetWordsResponseDTO.self,
            path
        )

        return response.words.enumerated().map { index, word in
            MemoCard(
                id: word.wordId,
                frontText: word.front,
                backText: word.back,
                difficulty: response.difficulty,
                orderIndex: index,
                color: colorForIndex(index)
            )
        }
    }

    private func colorForIndex(_ index: Int) -> Color {
        let palette: [Color] = [.blue, .green, .purple, .orange, .pink]
        return palette[index % palette.count]
    }
}
