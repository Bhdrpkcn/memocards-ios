import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var nav: NavigationCoordinator

    var body: some View {
        VStack(spacing: 16) {
            Text("Profile")
                .font(.title.bold())
            Text("Placeholder – later we'll show user progress, streaks, settings, etc.")
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
