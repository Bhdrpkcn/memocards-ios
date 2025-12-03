import SwiftUI

struct PickerView<Content: View>: View {

    let title: String
    let subtitle: String?
    let content: Content

    init(
        title: String,
        subtitle: String? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.subtitle = subtitle
        self.content = content()
    }

    var body: some View {
        VStack(spacing: 16) {
            VStack(spacing: 6) {
                Text(title)
                    .font(.title2.bold())
                    .multilineTextAlignment(.center)

                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
            .padding(.top, 24)

            content

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}
