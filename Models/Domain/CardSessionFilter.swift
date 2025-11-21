
import Foundation

enum CardSessionFilter: String, Codable {
    case all
    case known
    case review
    case custom

    var backendStatusParam: String? {
        switch self {
        case .all:
            return nil
        case .known:
            return "known"
        case .review:
            return "review"
        case .custom:
            return "custom"
        }
    }
}
