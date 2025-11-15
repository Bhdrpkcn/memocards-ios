import SwiftUI

enum CardSwipeDirection {
    case left
    case right
}

enum CardsFilter: String, CaseIterable, Identifiable {
    case all = "All"
    case known = "Known"
    case review = "Review"

    var id: String { rawValue }
}

@MainActor
final class CardsViewModel: ObservableObject {

    private let cardsService: CardsServiceProtocol
    private let statusStore: CardStatusStore

    @Published private(set) var allCards: [MemoCard] = []
    @Published private(set) var statuses: [String: CardStatus] = [:]
    @Published var filter: CardsFilter = .all {
        didSet {
            topCardIndex = 0
        }
    }

    @Published private(set) var topCardIndex: Int = 0

    // MARK: - Layout / Interaction Constants
    let cardWidth: CGFloat
    let swipeThreshold: CGFloat
    let maxProgressDistance: CGFloat

    // MARK: - Init
    init(
        cardsService: CardsServiceProtocol = LocalJSONCardsService(),
        statusStore: CardStatusStore = UserDefaultsCardStatusStore(),
        cardWidth: CGFloat = 180,
        swipeThreshold: CGFloat = 50,
        maxProgressDistance: CGFloat = 150
    ) {
        self.cardsService = cardsService
        self.statusStore = statusStore
        self.cardWidth = cardWidth
        self.swipeThreshold = swipeThreshold
        self.maxProgressDistance = maxProgressDistance

        loadInitialData()
    }

    // MARK: - Data Loading
    private func loadInitialData() {
        let cards = cardsService.loadCards()
        self.allCards = cards
        self.statuses = statusStore.loadStatuses()

        for card in cards {
            if statuses[card.id] == nil {
                statuses[card.id] = .unknown
            }
        }
        statusStore.saveStatuses(statuses)
    }

    // MARK: - Derived Data
    var activeCards: [MemoCard] {
        switch filter {
        case .all:
            return allCards
        case .known:
            return allCards.filter { statuses[$0.id] == .known }
        case .review:
            return allCards.filter { statuses[$0.id] == .review }
        }
    }

    var knownCount: Int {
        statuses.values.filter { $0 == .known }.count
    }

    var reviewCount: Int {
        statuses.values.filter { $0 == .review }.count
    }

    // MARK: - Stack Helpers
    func visualIndex(for index: Int) -> Int {
        guard !activeCards.isEmpty else { return 0 }
        return (index - topCardIndex + activeCards.count) % activeCards.count
    }

    func advanceTopCard() {
        guard !activeCards.isEmpty else { return }
        topCardIndex = (topCardIndex + 1) % activeCards.count
    }

    // MARK: - Swipe Handling
    func registerSwipe(_ direction: CardSwipeDirection) {
        guard !activeCards.isEmpty else { return }

        let currentCard = activeCards[topCardIndex]

        switch direction {
        case .right:
            statuses[currentCard.id] = .known
        case .left:
            statuses[currentCard.id] = .review
        }

        statusStore.saveStatuses(statuses)
    }
}
