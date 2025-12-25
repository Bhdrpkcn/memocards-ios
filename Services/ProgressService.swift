import Foundation

protocol ProgressServiceProtocol {
    func updateStatus(
        userId: Int,
        wordId: Int,
        status: CardStatusKind,
        fromLanguageCode: String,
        toLanguageCode: String
    ) async throws
}

final class ProgressService: ProgressServiceProtocol {

    private struct ProgressRequest: Encodable {
        let userId: Int
        let fromLanguageCode: String
        let toLanguageCode: String
        let status: CardStatusKind
    }

    func updateStatus(
        userId: Int,
        wordId: Int,
        status: CardStatusKind,
        fromLanguageCode: String,
        toLanguageCode: String
    ) async throws {
        let body = ProgressRequest(
            userId: userId,
            fromLanguageCode: fromLanguageCode,
            toLanguageCode: toLanguageCode,
            status: status
        )

        _ = try await APIConfig.client.request(
            ProgressResponseDTO.self,
            APIEndpoints.wordProgress(wordId: wordId),
            method: .POST,
            body: body
        )
    }
}
