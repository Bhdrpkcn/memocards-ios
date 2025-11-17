import Foundation

struct Deck: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let resourceName: String
    let description: String?

    init(
        id: String,
        name: String,
        resourceName: String,
        description: String? = nil
    ) {
        self.id = id
        self.name = name
        self.resourceName = resourceName
        self.description = description
    }
}
