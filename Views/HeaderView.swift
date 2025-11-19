import SwiftUI

struct HeaderView: View {

    @Binding var selectedTab: Tab
    @Binding var isInSession: Bool
    var onBackFromSession: () -> Void

    var body: some View {
        HStack {
            if isInSession {
                Button {
                    onBackFromSession()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 17, weight: .semibold))
                        Text("Back")
                            .font(.system(size: 20, weight: .semibold))
                    }
                }
            } else {
                Text("MemoCards")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(.primary)
            }

            Spacer()

            if !isInSession {
                Button {
                    //TODO: future: settings / deck list etc.
                } label: {
                    Image(systemName: "rectangle.stack")
                        .font(.system(size: 20, weight: .semibold))
                        .padding(8)
                }
            }
        }
        .padding(.horizontal)
        .padding(.top, 12)
        .padding(.bottom, 8)
        .background(.ultraThinMaterial)
    }
}
