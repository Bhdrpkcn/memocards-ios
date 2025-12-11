import Foundation

struct LanguagePreferenceStore {
    private static let key = "selectedLanguagePair"

    static func save(_ pair: LanguagePair) {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(pair) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    static func load() -> LanguagePair? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        let decoder = JSONDecoder()
        return try? decoder.decode(LanguagePair.self, from: data)
    }

    static func clear() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}
