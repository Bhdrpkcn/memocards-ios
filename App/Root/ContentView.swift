import SwiftUI

struct ContentView: View {

    @State private var selectedTab: Tab = .learn

    var body: some View {
        VStack(spacing: 0) {

            // MARK: - Header
            HeaderView(selectedTab: $selectedTab)

            // MARK: - Body
            ZStack {
                switch selectedTab {
                case .learn:
                    NavigationStack {
                        LearnView()
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
            FooterView(selectedTab: $selectedTab)
        }
        .ignoresSafeArea(.keyboard)
    }
}

enum Tab {
    case learn, exercise, library, profile
}
