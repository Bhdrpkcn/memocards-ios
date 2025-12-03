import SwiftUI

struct LibraryView: View {
    @EnvironmentObject private var nav: NavigationCoordinator

    var body: some View {
        VStack(spacing: 16) {
            Text("Library")
                .font(.title.bold())
            Text("Placeholder – later we'll show saved decks, collections, stats, etc.")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Button("Back to Home") {
                nav.reset()
            }
            .padding(.top, 24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}
