import Foundation

@MainActor
final class StartViewModel: ObservableObject {

    // MARK: - Step State

    @Published var step: StartStep = .chooseFromLanguage
    @Published var availableLanguages: [LanguageOption] = []

    // MARK: - Selected language state

    @Published var selectedFromCode: String?
    @Published var selectedToCode: String?

    // MARK: - Content state

    /// System word sets (WordSet -> Deck)
    @Published var decks: [Deck] = []

    /// User collections (LANGUAGE scope, filtered by toLanguageCode)
    @Published var collections: [Deck] = []

    @Published var selectedDeck: Deck?
    @Published var selectedFilter: CardSessionFilter = .all

    @Published var isLoadingContent = false
    @Published var errorMessage: String?

    private let deckService = DeckService()
    private let collectionsService = CollectionsService()

    init() {
        loadLanguageOptions()
    }

    // MARK: - Computed groups

    var easyDecks: [Deck] {
        decks.filter { $0.difficulty == .easy }
    }

    var mediumDecks: [Deck] {
        decks.filter { $0.difficulty == .medium }
    }

    var hardDecks: [Deck] {
        decks.filter { $0.difficulty == .hard }
    }

    // MARK: - Setup

    private func loadLanguageOptions() {
        // TODO: Later load from backend / languages endpoint.
        availableLanguages = [
            LanguageOption(code: "en", name: "English"),
            LanguageOption(code: "tr", name: "Turkish"),
            LanguageOption(code: "de", name: "German"),
            LanguageOption(code: "es", name: "Spanish"),
            LanguageOption(code: "fr", name: "French"),
        ]
    }

    // MARK: - Step transitions

    func selectFromLanguage(_ code: String) {
        selectedFromCode = code
        selectedToCode = nil
        decks = []
        collections = []
        selectedDeck = nil
        step = .chooseToLanguage(from: code)
    }

    func selectToLanguage(_ code: String) {
        guard let from = selectedFromCode, from != code else { return }
        selectedToCode = code
        step = .chooseContent(from: from, to: code)
    }

    func restartFlow() {
        selectedFromCode = nil
        selectedToCode = nil
        decks = []
        collections = []
        selectedDeck = nil
        selectedFilter = .all
        errorMessage = nil
        isLoadingContent = false
        step = .chooseFromLanguage
    }

    // MARK: - Load word sets + collections together

    func loadContentForCurrentPair(userId: Int) async {
        guard let from = selectedFromCode,
            let to = selectedToCode
        else { return }

        isLoadingContent = true
        errorMessage = nil

        do {
            async let wordSetsTask = deckService.fetchDecks(
                from: from,
                to: to,
                difficulty: nil
            )

            async let collectionsTask = collectionsService.fetchCollections(
                userId: userId,
                fromLanguageCode: from,
                toLanguageCode: to
            )

            let (wordSets, userCollections) = try await (wordSetsTask, collectionsTask)

            self.decks = wordSets
            self.collections = userCollections

            if selectedDeck == nil {
                selectedDeck = wordSets.first ?? userCollections.first
            }
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoadingContent = false
    }

    // MARK: - Filter selection

    func setFilter(_ filter: CardSessionFilter) {
        selectedFilter = filter
    }
}
