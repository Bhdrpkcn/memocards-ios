import SwiftUI

struct HeaderView: View {

    @Binding var isInSession: Bool

    let languagePair: LanguagePair?

    let onLanguageTap: () -> Void

    let onBackFromSession: () -> Void

    var body: some View {
        HStack(spacing: 12) {

            // MARK: - Left: Back button (only in session)
            if isInSession {
                Button {
                    onBackFromSession()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Back")
                            .font(.subheadline.weight(.semibold))
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemGray6))
                    )
                }
            } else {
                Spacer().frame(width: 0)
            }

            Spacer()

            // MARK: - Center: Language selector
            Button {
                onLanguageTap()
            } label: {
                VStack(spacing: 2) {
                    if let pair = languagePair {
                        Text(pair.displayText)
                            .font(.headline)
                        Text("Tap to change")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    } else {
                        Text("Choose languages")
                            .font(.headline)
                        Text("Tap to start")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.systemGray6))
                )
            }

            Spacer()

            // TODO: - Right: Decks icon (for future open collections screen later)
            Button {
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
