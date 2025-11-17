import Foundation

/// High-level category for filtering & UI.
enum CardStatusKind: String, Codable {
    case unknown
    case known
    case review
}

struct CardStatus: Codable {
    /// UI / filter category
    var kind: CardStatusKind

    /// SM-2 / spaced repetition fields
    var easeFactor: Double  // EF (default ~2.5)
    var intervalDays: Int  // current interval in days
    var repetitions: Int  // successful reviews in a row
    var nextReviewDate: Date?  // when the card is due next

    init(
        kind: CardStatusKind = .unknown,
        easeFactor: Double = 2.5,
        intervalDays: Int = 0,
        repetitions: Int = 0,
        nextReviewDate: Date? = nil
    ) {
        self.kind = kind
        self.easeFactor = easeFactor
        self.intervalDays = intervalDays
        self.repetitions = repetitions
        self.nextReviewDate = nextReviewDate
    }
}
