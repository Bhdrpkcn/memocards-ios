import SwiftUI

struct FooterView: View {

    @Binding var selectedTab: Tab

    var body: some View {
        HStack(spacing: 0) {

            footerItem(
                tab: .learn,
                icon: "bolt.fill",
                label: "Learn"
            )

            footerItem(
                tab: .exercise,
                icon: "dumbbell.fill",
                label: "Exercise"
            )

            footerItem(
                tab: .library,
                icon: "books.vertical.fill",
                label: "Library"
            )

            footerItem(
                tab: .profile,
                icon: "person.crop.circle",
                label: "Profile"
            )
        }
        .padding(.vertical, 10)
        .background(.ultraThinMaterial)
    }

    @ViewBuilder
    private func footerItem(tab: Tab, icon: String, label: String) -> some View {
        Button {
            selectedTab = tab
        } label: {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                Text(label)
                    .font(.caption)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 4)
            .foregroundStyle(selectedTab == tab ? .blue : .gray)
        }
    }
}
