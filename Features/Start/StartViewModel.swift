import Foundation

@MainActor
final class StartViewModel: ObservableObject {

    @Published var step: StartStep = .chooseFromLanguage
    @Published var availableLanguages: [LanguageOption] = []

    @Published var selectedFromCode: String?
    @Published var selectedToCode: String?

    @Published var decks: [Deck] = []
    @Published var selectedDeck: Deck?
    @Published var selectedFilter: CardSessionFilter = .all

    @Published var isLoadingContent = false
    @Published var errorMessage: String?

    private let deckService = DeckService()

    init() {
        loadLanguageOptions()
    }

    // MARK: - Setup
    private func loadLanguageOptions() {
        // TODO: Later load from backend / languages endpoint.
        // For now, static list.
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
        selectedDeck = nil
        selectedFilter = .all
        errorMessage = nil
        isLoadingContent = false
        step = .chooseFromLanguage
    }

    // MARK: - Deck loading
    func loadDecksForCurrentPair() async {
        guard let from = selectedFromCode,
            let to = selectedToCode
        else {
            return
        }

        isLoadingContent = true
        errorMessage = nil

        do {
            let result = try await deckService.fetchDecks(
                from: from,
                to: to,
                difficulty: nil
            )
            decks = result
            if selectedDeck == nil {
                selectedDeck = result.first
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
