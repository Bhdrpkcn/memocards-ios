import SwiftUI

struct FooterView: View {

    @EnvironmentObject private var nav: NavigationCoordinator

    var body: some View {
        HStack {
            footerButton(
                title: "Learn",
                systemImage: "book.closed",
                route: .home
            )

            Spacer()

            footerButton(
                title: "Library",
                systemImage: "books.vertical",
                route: .library
            )

            Spacer()

            footerButton(
                title: "Profile",
                systemImage: "person.crop.circle",
                route: .profile
            )
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial)
    }

    private func footerButton(
        title: String,
        systemImage: String,
        route: Route
    ) -> some View {
        Button {
            switch route {
            case .home:
                nav.goHome()
            case .library:
                nav.openLibrary()
            case .profile:
                nav.openProfile()
            }
        } label: {
            VStack(spacing: 4) {
                Image(systemName: systemImage)
                    .font(.system(size: 18, weight: .semibold))
                Text(title)
                    .font(.caption)
            }
            .foregroundColor(
                nav.route == route
                    ? Color.accentColor
                    : Color.secondary
            )
        }
    }
}
