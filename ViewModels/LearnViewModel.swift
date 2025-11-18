import Foundation

@MainActor
final class LearnViewModel: ObservableObject {

    @Published var decks: [Deck] = []
    @Published var selectedDeck: Deck?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let deckService = DeckService()

    func loadDecks() async {
        isLoading = true
        errorMessage = nil

        do {
            let result = try await deckService.fetchDecks()
            self.decks = result
            if selectedDeck == nil {
                self.selectedDeck = result.first
            }
        } catch {
            self.errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
