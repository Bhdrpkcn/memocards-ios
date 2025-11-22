import Foundation

enum CardSessionFilter: String, Codable {
    case all
    case known
    case review

    var backendStatusParam: String? {
        switch self {
        case .all:
            return nil
        case .known:
            return "known"
        case .review:
            return "review"
        }
    }
}
