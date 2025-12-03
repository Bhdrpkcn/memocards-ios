import Foundation

struct ProgressResponseDTO: Decodable {
    let id: Int
    let statusKind: CardStatusKind
}
