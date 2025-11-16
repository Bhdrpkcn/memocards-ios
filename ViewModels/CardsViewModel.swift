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
    private let haptics: HapticsServiceProtocol

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
        haptics: HapticsServiceProtocol = HapticsService.shared,
        cardWidth: CGFloat = 180,
        swipeThreshold: CGFloat = 50,
        maxProgressDistance: CGFloat = 150
    ) {
        self.cardsService = cardsService
        self.statusStore = statusStore
        self.haptics = haptics
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
                statuses[card.id] = CardStatus(kind: .unknown)
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
            return allCards.filter { statuses[$0.id]?.kind == .known }
        case .review:
            return allCards.filter { statuses[$0.id]?.kind == .review }
        }
    }

    var knownCount: Int {
        statuses.values.filter { $0.kind == .known }.count
    }

    var reviewCount: Int {
        statuses.values.filter { $0.kind == .review }.count
    }

    var totalCardCount: Int {
        allCards.count
    }

    var memorizationProgress: Double {
        guard totalCardCount > 0 else { return 0 }
        return Double(knownCount) / Double(totalCardCount)
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
        let id = currentCard.id

        var status = statuses[id] ?? CardStatus(kind: .unknown)

        switch direction {
        case .right:
            status.kind = .known
            haptics.success()
        case .left:
            status.kind = .review
            haptics.review()
        }

        statuses[id] = status
        statusStore.saveStatuses(statuses)
    }
}
