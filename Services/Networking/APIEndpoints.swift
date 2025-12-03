import Foundation

enum APIEndpoints {

    // MARK: - Word sets
    static func wordSets(
        from: String,
        to: String,
        difficulty: CardDifficulty? = nil
    ) -> String {
        var base = "word-sets?from=\(from)&to=\(to)"
        if let difficulty {
            base += "&difficulty=\(difficulty.rawValue)"
        }
        return base
    }

    static func wordSetWords(
        id: Int,
        from: String,
        to: String
    ) -> String {
        "word-sets/\(id)/words?from=\(from)&to=\(to)"
    }

    static func wordSetProgressWords(
        id: Int,
        userId: Int,
        from: String,
        to: String,
        status: String
    ) -> String {
        "word-sets/\(id)/words/progress?userId=\(userId)&from=\(from)&to=\(to)&status=\(status)"
    }

    // MARK: - Progress
    static func wordProgress(wordId: Int) -> String {
        "words/\(wordId)/progress"
    }

    // MARK: - Collections
    static func collections(
        userId: Int,
        scope: CollectionScope? = nil
    ) -> String {
        var base = "collections?userId=\(userId)"
        if let scope {
            base += "&scope=\(scope.rawValue)"
        }
        return base
    }

    static func collectionItems(collectionId: Int) -> String {
        "collections/\(collectionId)/items"
    }

    static func collection(collectionId: Int, userId: Int) -> String {
        "collections/\(collectionId)?userId=\(userId)"
    }

    static func collectionWords(
        collectionId: Int,
        from: String,
        to: String
    ) -> String {
        "collections/\(collectionId)/words?from=\(from)&to=\(to)"
    }

}
