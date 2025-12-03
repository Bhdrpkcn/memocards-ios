import Foundation
import SwiftUI

final class CardService {

    func fetchCards(
        deck: Deck,
        filter: CardSessionFilter,
        userId: Int
    ) async throws -> [MemoCard] {

        if deck.isCustom {
            return try await fetchCollectionCards(
                collectionId: deck.id,
                fromLanguageCode: deck.fromLanguageCode,
                toLanguageCode: deck.toLanguageCode
            )
        } else {
            switch filter {
            case .all:
                return try await fetchWordSetCardsAll(
                    wordSetId: deck.id,
                    fromLanguageCode: deck.fromLanguageCode,
                    toLanguageCode: deck.toLanguageCode
                )

            case .known, .review:
                guard let status = filter.backendStatusParam else {
                    return try await fetchWordSetCardsAll(
                        wordSetId: deck.id,
                        fromLanguageCode: deck.fromLanguageCode,
                        toLanguageCode: deck.toLanguageCode
                    )
                }

                return try await fetchWordSetCardsByStatus(
                    wordSetId: deck.id,
                    userId: userId,
                    fromLanguageCode: deck.fromLanguageCode,
                    toLanguageCode: deck.toLanguageCode,
                    status: status
                )
            }
        }
    }

    // MARK: - Word sets: ALL
    private func fetchWordSetCardsAll(
        wordSetId: Int,
        fromLanguageCode: String,
        toLanguageCode: String
    ) async throws -> [MemoCard] {

        let path = APIEndpoints.wordSetWords(
            id: wordSetId,
            from: fromLanguageCode,
            to: toLanguageCode
        )

        let dto = try await APIConfig.client.request(
            WordSetWordsResponseDTO.self,
            path
        )

        return dto.words.enumerated().map { index, w in
            MemoCard(
                id: w.wordId,
                frontText: w.front,
                backText: w.back,
                difficulty: dto.difficulty,
                orderIndex: index,
                color: colorForIndex(index)
            )
        }
    }

    // MARK: - Word sets: filtered by status (Known / Review)
    private func fetchWordSetCardsByStatus(
        wordSetId: Int,
        userId: Int,
        fromLanguageCode: String,
        toLanguageCode: String,
        status: String
    ) async throws -> [MemoCard] {

        let path = APIEndpoints.wordSetProgressWords(
            id: wordSetId,
            userId: userId,
            from: fromLanguageCode,
            to: toLanguageCode,
            status: status
        )

        let dto = try await APIConfig.client.request(
            WordSetWordsResponseDTO.self,
            path
        )

        return dto.words.enumerated().map { index, w in
            MemoCard(
                id: w.wordId,
                frontText: w.front,
                backText: w.back,
                difficulty: dto.difficulty,
                orderIndex: index,
                color: colorForIndex(index)
            )
        }
    }

    // MARK: - Collections: words in a custom collection
    private func fetchCollectionCards(
        collectionId: Int,
        fromLanguageCode: String,
        toLanguageCode: String
    ) async throws -> [MemoCard] {

        let path = APIEndpoints.collectionWords(
            collectionId: collectionId,
            from: fromLanguageCode,
            to: toLanguageCode
        )

        let dto = try await APIConfig.client.request(
            CollectionWordsResponseDTO.self,
            path
        )

        return dto.words.enumerated().map { index, w in
            MemoCard(
                id: w.wordId,
                frontText: w.front,
                backText: w.back,
                difficulty: nil,
                orderIndex: index,
                color: colorForIndex(index)
            )
        }
    }

    // MARK: - Color helper
    private func colorForIndex(_ index: Int) -> Color {
        let palette: [Color] = [.blue, .green, .purple, .orange, .pink]
        return palette[index % palette.count]
    }
}
