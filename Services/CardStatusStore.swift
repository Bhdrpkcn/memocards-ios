import Foundation

protocol CardStatusStore {
    func loadStatuses() -> [String: CardStatus]
    func saveStatuses(_ statuses: [String: CardStatus])
}

final class UserDefaultsCardStatusStore: CardStatusStore {

    private let storageKey = "memocards.cardStatuses.v2"
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func loadStatuses() -> [String: CardStatus] {
        guard let data = defaults.data(forKey: storageKey) else {
            return [:]
        }

        do {
            let decoded = try JSONDecoder().decode([String: CardStatus].self, from: data)
            return decoded
        } catch {
            print("⚠️ Failed to decode card statuses: \(error)")
            return [:]
        }
    }

    func saveStatuses(_ statuses: [String: CardStatus]) {
        do {
            let data = try JSONEncoder().encode(statuses)
            defaults.set(data, forKey: storageKey)
        } catch {
            print("⚠️ Failed to encode card statuses: \(error)")
        }
    }
}
