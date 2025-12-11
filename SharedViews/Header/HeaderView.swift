import SwiftUI

struct HeaderView: View {

    @Binding var isInSession: Bool

    let languagePair: LanguagePair?

    let onLanguageTap: () -> Void
    let onBackFromSession: () -> Void
    let onDecksTap: () -> Void

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
                }
            } else {
                Spacer().frame(width: 0)
            }

            Spacer()

            // MARK: - Center: flags + target language + arrow
            Button {
                onLanguageTap()
            } label: {
                HStack(spacing: 8) {
                    if let pair = languagePair {
                        // Flags stacked
                        ZStack {
                            Text(pair.fromFlagEmoji)
                                .font(.title3)
                                .offset(x: -6, y: -3)

                            Text(pair.toFlagEmoji)
                                .font(.title)
                                .offset(x: 6, y: 3)
                        }
                        .frame(width: 40, height: 28)

                        HStack(spacing: 4) {
                            Text(pair.toName)
                                .font(.headline)

                            Image(systemName: "chevron.down")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.secondary)
                        }
                    } else {
                        // No pair yet → prompt
                        HStack(spacing: 4) {
                            Text("Choose languages")
                                .font(.headline)
                            Image(systemName: "chevron.down")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .opacity(languagePair == nil ? 0 : 1)
            .animation(.easeInOut, value: languagePair != nil)

            Spacer()

            // MARK: - Right: Decks icon (future collections screen, etc.)
            Button {
                onDecksTap()
            } label: {
                Image(systemName: "rectangle.stack")
                    .font(.system(size: 20, weight: .semibold))
                    .padding(8)
            }
        }
        .padding(.horizontal)
        .padding(.top, 12)
        .padding(.bottom, 8)
    }
}
