import SwiftUI

struct ContentView: View {

    @State private var isInSession = false
    @State private var selectedTab: Tab = .learn
    @State private var activeDeck: Deck?
    @State private var activeFilter: CardSessionFilter = .all


    @State private var languagePair: LanguagePair?

    // TODO: later this will come from auth / user profile
    private let userId: Int = 1

    var body: some View {
        VStack(spacing: 0) {

            // MARK: - Header
            HeaderView(
                selectedTab: $selectedTab,
                isInSession: $isInSession,
                languagePair: languagePair,
                onLanguageTap: handleLanguageTap,
                onBackFromSession: endSession
            )

            Divider()
                .overlay(Color.white.opacity(0.7))
                .frame(height: 1)

            // MARK: - Main content area
            ZStack {
                switch selectedTab {
                case .learn:
                    learnTabBody

                case .exercise:
                    Text("Exercise tab")
                        .font(.title2)
                        .foregroundColor(.secondary)

                case .library:
                    Text("Library tab")
                        .font(.title2)
                        .foregroundColor(.secondary)

                case .profile:
                    Text("Profile tab")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemBackground))

            // MARK: - Footer
            if !isInSession {
                Divider()
                    .overlay(Color.white.opacity(0.7))
                    .frame(height: 1)

                FooterView(selectedTab: $selectedTab)
            }
        }
        .ignoresSafeArea(.keyboard)
    }

    // MARK: - Learn tab body
    @ViewBuilder
    private var learnTabBody: some View {
        if isInSession, let deck = activeDeck {
            CardDeckView(
                deck: deck,
                filter: activeFilter,
                userId: userId
            )
        } else {
            LearnView { deck, filter in
                startSession(with: deck, filter: filter)
            }
        }
    }

    // MARK: - Session / header actions

    private func startSession(with deck: Deck, filter: CardSessionFilter) {
        activeDeck = deck
        activeFilter = filter
        isInSession = true

        languagePair = LanguagePair(
            fromCode: deck.fromLanguageCode,
            toCode: deck.toLanguageCode
        )
    }

    private func endSession() {
        isInSession = false
        activeDeck = nil
    }

    private func handleLanguageTap() {
        //TODO:
        // Phase A: just a stub.
        // Later (Phase C) this will:
        // - Open StartView
        // - Let user change from/to languages and word set.
        // For now we can leave it empty or maybe reset state:
        // languagePair = nil
    }
}

enum Tab {
    case learn, exercise, library, profile
}
