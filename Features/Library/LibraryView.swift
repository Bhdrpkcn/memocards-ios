import SwiftUI

struct LibraryView: View {
    @EnvironmentObject private var nav: NavigationCoordinator

    var body: some View {
        VStack(spacing: 16) {
            Text("Library")
                .font(.title.bold())
            Text("Placeholder – later we'll show saved decks, collections, stats, etc.")
                .font(.subheadline)
                .foregroundColor(AppTheme.Colors.secondary)

            Button("Back to Home") {
                nav.reset()
            }
            .padding(.top, 24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppTheme.Colors.screenBackground)
    }
}
