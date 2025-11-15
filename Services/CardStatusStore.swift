import Foundation

protocol CardStatusStore {
    func loadStatuses() -> [String: CardStatus]
    func saveStatuses(_ statuses: [String: CardStatus])
}

final class UserDefaultsCardStatusStore: CardStatusStore {

    private let storageKey = "memocards.cardStatuses.v1"
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func loadStatuses() -> [String: CardStatus] {
        guard
            let raw = defaults.dictionary(forKey: storageKey) as? [String: String]
        else {
            return [:]
        }

        var result: [String: CardStatus] = [:]
        for (id, rawValue) in raw {
            if let status = CardStatus(rawValue: rawValue) {
                result[id] = status
            }
        }
        return result
    }

    func saveStatuses(_ statuses: [String: CardStatus]) {
        let raw = statuses.mapValues { $0.rawValue }
        defaults.set(raw, forKey: storageKey)
    }
}
