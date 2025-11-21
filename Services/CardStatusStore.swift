import Foundation

protocol CardStatusStore {
    func loadStatuses() -> [Int: CardStatus]
    func saveStatuses(_ statuses: [Int: CardStatus])
}

final class UserDefaultsCardStatusStore: CardStatusStore {

    private let storageKey = "memocards.cardStatuses.v2"
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func loadStatuses() -> [Int: CardStatus] {
        guard let data = defaults.data(forKey: storageKey) else {
            return [:]
        }

        do {
            let decoded = try JSONDecoder().decode([Int: CardStatus].self, from: data)
            return decoded
        } catch {
            print("⚠️ Failed to decode CardStatus map:", error)
            return [:]
        }
    }

    func saveStatuses(_ statuses: [Int: CardStatus]) {
        do {
            let data = try JSONEncoder().encode(statuses)
            defaults.set(data, forKey: storageKey)
        } catch {
            print("⚠️ Failed to encode CardStatus map:", error)
        }
    }
}
