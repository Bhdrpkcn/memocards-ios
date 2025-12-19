import SwiftUI

struct ContentView: View {

    @EnvironmentObject private var nav: NavigationCoordinator

    @State private var isInSession = false

    //TODO: Change Deck-based session data into the SessionConfig
    @State private var activeDeck: Deck?
    @State private var activeFilter: CardSessionFilter = .all

    //TODO: later from auth
    private let userId: Int = 1

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {

                // MARK: - Main body
                StartView(
                    isInSession: $isInSession,
                    activeDeck: $activeDeck,
                    activeFilter: $activeFilter,
                    userId: userId,
                    onStartSession: { deck, filter in
                        startSession(with: deck, filter: filter)
                    },
                    onEndSession: {
                        endSession()
                    },
                    onOpenLibrary: {
                        nav.openLibrary()
                    }

                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)

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
            .navigationDestination(isPresented: nav.isLibraryActive) {
                LibraryView()
            }

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
        nav.goHome()
    }

    private func endSession() {
        isInSession = false
        activeDeck = nil
    }
}
