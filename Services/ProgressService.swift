import Foundation

final class ProgressService {

    private let userId: Int

    init(userId: Int) {
        self.userId = userId
    }

    private struct ProgressRequest: Encodable {
        let userId: Int
        let fromLanguageCode: String
        let toLanguageCode: String
        let status: CardStatusKind
    }

    func updateStatus(
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

struct ProgressResponseDTO: Decodable {
    let id: Int
    let statusKind: CardStatusKind
}
