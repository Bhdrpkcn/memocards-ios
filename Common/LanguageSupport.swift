import Foundation

func languageDisplayName(for code: String) -> String {
    switch code.lowercased() {
    case "en": return "English"
    case "tr": return "Turkish"
    case "fr": return "French"
    case "de": return "German"
    case "es": return "Spanish"
    default:
        // Fallback: system locale
        if let localized = Locale.current.localizedString(forLanguageCode: code) {
            return localized.capitalized
        }
        return code.uppercased()
    }
}

// MARK: - Language → Region code mapping for flags
private let languageToRegionCode: [String: String] = [
    "en": "GB",
    "tr": "TR",
    "fr": "FR",
    "de": "DE",
    "es": "ES",
]

func languageFlagEmoji(for languageCode: String) -> String {
    let lower = languageCode.lowercased()
    let regionCode = languageToRegionCode[lower] ?? lower
    return flagEmojiFromRegionCode(regionCode)
}

private func flagEmojiFromRegionCode(_ regionCode: String) -> String {
    let base: UInt32 = 127397
    let uppercased = regionCode.uppercased()

    guard uppercased.count == 2,
        uppercased.unicodeScalars.allSatisfy({ $0.value >= 65 && $0.value <= 90 })
    else {
        return "❓"
    }

    var flag = ""
    for scalar in uppercased.unicodeScalars {
        if let unicode = UnicodeScalar(base + scalar.value) {
            flag.append(String(unicode))
        }
    }
    return flag
}
