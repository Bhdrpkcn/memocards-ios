import Foundation

protocol CardStatusStore {
    func loadStatuses() -> [Int: CardStatus]
    func saveStatuses(_ statuses: [Int: CardStatus])
}

final class UserDefaultsCardStatusStore: CardStatusStore {

    private let storageKey = "memocards.cardStatuses.v1"
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func loadStatuses() -> [Int: CardStatus] {
        guard
            let raw = defaults.dictionary(forKey: storageKey) as? [String: String]
        else {
            return [:]
        }

        var result: [Int: CardStatus] = [:]

        for (key, rawValue) in raw {
            guard
                let id = Int(key),
                let status = CardStatus(rawValue: rawValue)
            else {
                continue
            }

            result[id] = status
        }

        return result
    }

    func saveStatuses(_ statuses: [Int: CardStatus]) {
        let raw: [String: String] = statuses.reduce(into: [:]) { dict, element in
            dict[String(element.key)] = element.value.rawValue
        }

        defaults.set(raw, forKey: storageKey)
    }
}
