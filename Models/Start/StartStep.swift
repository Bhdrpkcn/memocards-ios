import Foundation

enum StartStep: Equatable {
    case chooseFromLanguage
    case chooseToLanguage(from: String)
    case chooseContent(from: String, to: String)
}
