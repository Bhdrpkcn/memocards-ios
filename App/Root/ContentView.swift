import SwiftUI

struct ContentView: View {

    @EnvironmentObject private var nav: NavigationCoordinator

    @State private var isInSession = false

    //TODO: Change Deck-based session data into the SessionConfig
    @State private var activeDeck: Deck?
    @State private var activeFilter: CardSessionFilter = .all

    @State private var languagePair: LanguagePair?

    //TODO: later from auth
    private let userId: Int = 1

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {

                // MARK: - Header
                HeaderView(
                    isInSession: $isInSession,
                    languagePair: languagePair,
                    onLanguageTap: handleLanguageTap,
                    onBackFromSession: endSession
                )

                Divider()
                    .overlay(Color.white.opacity(0.7))
                    .frame(height: 1)

                // MARK: - Main body (root = Learn/Home via StartView)
                StartView(
                    languagePair: languagePair,
                    isInSession: $isInSession,
                    activeDeck: $activeDeck,
                    activeFilter: $activeFilter,
                    userId: userId,
                    onStartSession: { deck, filter in
                        startSession(with: deck, filter: filter)
                    }
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemBackground))

                // MARK: - Footer
                if !isInSession {
                    Divider()
                        .overlay(Color.white.opacity(0.7))
                        .frame(height: 1)

                    FooterView()
                }
            }
            .ignoresSafeArea(.keyboard)

            // MARK: - DESTINATIONS
            /// Library
            .navigationDestination(isPresented: nav.isLibraryActive) {
                LibraryView()
            }

            /// Profile
            .navigationDestination(isPresented: nav.isProfileActive) {
                ProfileView()
            }
        }
    }

    // MARK: - Session / header actions
    private func startSession(with deck: Deck, filter: CardSessionFilter) {
        activeDeck = deck
        activeFilter = filter
        isInSession = true

        //TODO: later derive it from word-set collection instead of deck
        languagePair = LanguagePair(
            fromCode: deck.fromLanguageCode,
            toCode: deck.toLanguageCode
        )

        nav.goHome()
    }

    private func endSession() {
        isInSession = false
        activeDeck = nil
    }

    private func handleLanguageTap() {
        nav.goHome()
    }
}
