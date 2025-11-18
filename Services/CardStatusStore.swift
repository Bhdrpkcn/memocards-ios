//import Foundation
//
//protocol CardStatusStore {
//    func loadStatuses() -> [Int: CardStatus]
//    func saveStatuses(_ statuses: [Int: CardStatus])
//}
//
//final class UserDefaultsCardStatusStore: CardStatusStore {
//
//    private let storageKey = "memocards.cardStatuses.v1"
//    private let defaults: UserDefaults
//
//    init(defaults: UserDefaults = .standard) {
//        self.defaults = defaults
//    }
//
//    func loadStatuses() -> [Int: CardStatus] {
//        guard
//            let raw = defaults.dictionary(forKey: storageKey) as? [String: String]
//        else {
//            return [:]
//        }
//
//        var result: [Int: CardStatus] = [:]
//
//        for (key, rawValue) in raw {
//            guard
//                let id = Int(key),
//                let status = CardStatus(rawValue: rawValue)
//            else {
//                continue
//            }
//
//            result[id] = status
//        }
//
//        return result
//    }
//
//    func saveStatuses(_ statuses: [Int: CardStatus]) {
//        let raw: [String: String] = statuses.reduce(into: [:]) { dict, element in
//            dict[String(element.key)] = element.value.rawValue
//        }
//
//        defaults.set(raw, forKey: storageKey)
//    }
//}

import Foundation

protocol CardStatusStore {
    func loadStatuses() -> [Int: CardStatus]
    func saveStatuses(_ statuses: [Int: CardStatus])
}

final class UserDefaultsCardStatusStore: CardStatusStore {

    // bumped to v2 since format changed from String to JSON'ed struct
    private let storageKey = "memocards.cardStatuses.v2"

    private let defaults: UserDefaults
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func loadStatuses() -> [Int: CardStatus] {
        guard let data = defaults.data(forKey: storageKey) else {
            return [:]
        }

        do {
            let decoded = try decoder.decode([Int: CardStatus].self, from: data)
            return decoded
        } catch {
            // if decoding fails (old format, corrupted data) just reset to empty
            print("⚠️ Failed to decode CardStatus dictionary: \(error)")
            return [:]
        }
    }

    func saveStatuses(_ statuses: [Int: CardStatus]) {
        do {
            let data = try encoder.encode(statuses)
            defaults.set(data, forKey: storageKey)
        } catch {
            print("⚠️ Failed to encode CardStatus dictionary: \(error)")
        }
    }
}
