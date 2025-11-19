import SwiftUI

struct ContentView: View {

    @State private var isInSession = false
    @State private var selectedTab: Tab = .learn
    @State private var activeDeck: Deck?

    var body: some View {
        VStack(spacing: 0) {

            // MARK: - Header
            HeaderView(
                selectedTab: $selectedTab,
                isInSession: $isInSession,
                onBackFromSession: {
                    isInSession = false
                    activeDeck = nil
                    selectedTab = .learn
                }
            )

            // MARK: - Body
            ZStack {
                switch selectedTab {
                case .learn:
                    if let deck = activeDeck, isInSession {
                        CardDeckView(deck: deck)
                    } else {
                        LearnView(
                            onStartSession: { deck in
                                activeDeck = deck
                                isInSession = true
                            }
                        )
                    }

                case .exercise:
                    Text("Exercise Placeholder")

                case .library:
                    Text("Library Placeholder")

                case .profile:
                    Text("Profile Placeholder")
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // MARK: - Footer Navigation
            if !isInSession {
                Divider()
                    .overlay(Color.white.opacity(0.7))
                    .frame(height: 1)

                FooterView(selectedTab: $selectedTab)
            }
        }
        .ignoresSafeArea(.keyboard)
    }
}

enum Tab {
    case learn, exercise, library, profile
}
