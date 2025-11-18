import SwiftUI

struct HeaderView: View {

    @Binding var selectedTab: Tab

    var body: some View {
        HStack {
            Text("MemoCards")
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(.primary)

            Spacer()

            // Small placeholder button for future deck selection
            Button {
                // later → open deck list
            } label: {
                Image(systemName: "rectangle.stack")
                    .font(.system(size: 20, weight: .semibold))
                    .padding(8)
            }
        }
        .padding(.horizontal)
        .padding(.top, 12)
        .padding(.bottom, 8)
        .background(.ultraThinMaterial)
    }
}
