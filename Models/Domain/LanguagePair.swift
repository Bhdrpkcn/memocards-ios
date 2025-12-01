import Foundation

struct LanguagePair: Equatable, Codable {
    let fromCode: String
    let toCode: String

    var displayText: String {
        "\(fromCode.uppercased()) → \(toCode.uppercased())"
    }

    var descriptionText: String {
        "\(fromCode.uppercased()) to \(toCode.uppercased())"
    }
}
