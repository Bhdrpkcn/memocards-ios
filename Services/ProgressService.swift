import Foundation

final class ProgressService {

    private let userId: Int

    init(userId: Int) {
        self.userId = userId
    }

    private struct ProgressRequest: Encodable {
        let userId: Int
        let status: CardStatusKind
    }

    func updateStatus(cardId: Int, status: CardStatusKind) async throws {
        let body = ProgressRequest(userId: userId, status: status)

        _ = try await APIConfig.client.request(
            ProgressResponseDTO.self,
            "cards/\(cardId)/progress",
            method: .POST,
            body: body
        )
    }
}

// TODO: For now we only care that decoding succeeds.
/// Backend returns a lot more, but we don’t *need* it yet.
struct ProgressResponseDTO: Decodable {
    let id: Int
    let statusKind: CardStatusKind
}
