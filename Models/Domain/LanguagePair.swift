import Foundation

struct LanguagePair: Equatable, Codable {
    let fromCode: String
    let toCode: String

    // MARK: - Flags

    var fromFlagEmoji: String {
        languageFlagEmoji(for: fromCode)
    }

    var toFlagEmoji: String {
        languageFlagEmoji(for: toCode)
    }

    // MARK: - Names

    var fromName: String {
        languageDisplayName(for: fromCode)
    }

    var toName: String {
        languageDisplayName(for: toCode)
    }

    // MARK: - Texts for UI

    /// "EN → TR"
    var displayText: String {
        "\(fromCode.uppercased()) → \(toCode.uppercased())"
    }

    /// "English to Turkish"
    var descriptionText: String {
        "\(fromName) to \(toName)"
    }

    /// "English → Turkish"
    var fullArrowText: String {
        "\(fromName) → \(toName)"
    }
}
