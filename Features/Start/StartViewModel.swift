import Foundation

enum DeckSource: String, CaseIterable {
    case premade = "Premade"
    case user = "User's"
}

@MainActor
final class StartViewModel: ObservableObject {
    
    // MARK: - Persistent UI State
        @Published var selectedDeckSource: DeckSource = .premade

    // MARK: - Callbacks to StartView
    var onLanguagePairConfirmed: ((LanguagePair) -> Void)?
    var onLanguageReset: (() -> Void)?

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
    //TODO: use isLoading state for languages also
    @Published var isLoadingLanguages = false
    @Published var errorMessage: String?

    private let deckService: any DeckServiceProtocol
    private let collectionsService: any CollectionsServiceProtocol
    private let languageService: any LanguageServiceProtocol
    
    init(
        deckService: any DeckServiceProtocol = DeckService(),
        collectionsService: any CollectionsServiceProtocol = CollectionsService(),
        languageService: any LanguageServiceProtocol = LanguageService()
    ) {
        self.deckService = deckService
        self.collectionsService = collectionsService
        self.languageService = languageService
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
    func loadLanguageOptions() async {
        do {
            let options = try await languageService.fetchLanguages()
            await MainActor.run {
                self.availableLanguages = options
            }
        } catch {
            // Fallback if backend fails
            await MainActor.run {
                self.availableLanguages = [
                    LanguageOption(code: "en", name: "English"),
                    LanguageOption(code: "tr", name: "Turkish"),
                    LanguageOption(code: "de", name: "German"),
                    LanguageOption(code: "es", name: "Spanish"),
                    LanguageOption(code: "fr", name: "French"),
                ]
            }
        }
    }

    func applyLanguagePair(_ pair: LanguagePair?) {
        if let pair = pair {
            selectedFromCode = pair.fromCode
            selectedToCode = pair.toCode
            step = .chooseContent(from: pair.fromCode, to: pair.toCode)

            decks = []
            collections = []
            selectedDeck = nil
            errorMessage = nil
        } else {
            restartFlow()
        }
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
    }

    func confirmLanguages() {
        guard let from = selectedFromCode,
            let to = selectedToCode
        else { return }

        let pair = LanguagePair(fromCode: from, toCode: to)
        LanguagePreferenceStore.save(pair)

        onLanguagePairConfirmed?(pair)

        step = .chooseContent(from: from, to: to)
    }

    func startLanguageChangeFlow(currentPair: LanguagePair?) {
        if let pair = currentPair {
            selectedFromCode = pair.fromCode
            selectedToCode = pair.toCode
            step = .chooseToLanguage(from: pair.fromCode)
        } else {
            restartFlow()
        }
    }

    func restartFlow() {
        LanguagePreferenceStore.clear()
        selectedFromCode = nil
        selectedToCode = nil
        decks = []
        collections = []
        selectedDeck = nil
        selectedFilter = .all
        errorMessage = nil
        isLoadingContent = false
        step = .chooseFromLanguage

        onLanguageReset?()
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
