import Foundation

struct LanguageOption: Identifiable, Equatable {
    let id: String
    let code: String
    let name: String

    init(code: String, name: String) {
        self.id = code
        self.code = code
        self.name = name
    }
}
