import SwiftUI

struct DeckSelectionView: View {

    let easyDecks: [Deck]
    let mediumDecks: [Deck]
    let hardDecks: [Deck]
    let collections: [Deck]

    let errorMessage: String?
    let isLoading: Bool

    @Binding var selectedDeck: Deck?
    @Binding var selectedFilter: CardSessionFilter

    let onStart: () -> Void
    let onChangeLanguages: () -> Void

    var body: some View {
        VStack(spacing: 20) {

            if isLoading {
                ProgressView("Loading your decks...")
                    .padding(.top, 8)
            }

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {

                    if !easyDecks.isEmpty {
                        deckSection(
                            title: "Easy Words",
                            subtitle: "Great for warming up",
                            decks: easyDecks
                        )
                    }

                    if !mediumDecks.isEmpty {
                        deckSection(
                            title: "Medium Words",
                            subtitle: "A bit more challenge",
                            decks: mediumDecks
                        )
                    }

                    if !hardDecks.isEmpty {
                        deckSection(
                            title: "Hard Words",
                            subtitle: "For serious practice",
                            decks: hardDecks
                        )
                    }

                    if !collections.isEmpty {
                        deckSection(
                            title: "Your Collections",
                            subtitle: "Custom decks you saved",
                            decks: collections,
                            isCollectionSection: true
                        )
                    }
                }
                .padding(.top, 8)
            }

            if let errorMessage, !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
            }

            // Filter chips
            HStack(spacing: 22) {
                filterItem(icon: "circle.grid.3x3", label: "All", type: .all)
                filterItem(icon: "checkmark.seal.fill", label: "Known", type: .known)
                filterItem(icon: "arrow.triangle.2.circlepath", label: "Review", type: .review)
            }
            .padding(.top, 8)

            // Start button
            Button(action: onStart) {
                Text("Start")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(selectedDeck == nil ? Color.gray : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(14)
                    .padding(.horizontal, 40)
            }
            .disabled(selectedDeck == nil)
            .padding(.bottom, 12)
        }
        .padding(.horizontal, 16)
    }

    // MARK: - Sections

    @ViewBuilder
    private func deckSection(
        title: String,
        subtitle: String? = nil,
        decks: [Deck],
        isCollectionSection: Bool = false
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                if let subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            VStack(spacing: 10) {
                ForEach(decks, id: \.id) { deck in
                    deckRow(deck: deck, isCollection: isCollectionSection)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private func deckRow(deck: Deck, isCollection: Bool) -> some View {
        let isSelected = selectedDeck == deck

        Button {
            selectedDeck = deck
        } label: {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(deck.name)
                        .font(.subheadline.weight(.semibold))

                    if isCollection {
                        if let count = deck.cardCount {
                            Text("\(count) words")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    } else if let difficulty = deck.difficulty {
                        Text(difficulty.rawValue.capitalized)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }

                    if let desc = deck.description, !desc.isEmpty {
                        Text(desc)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.blue)
                }
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(
                        isSelected
                            ? Color.blue.opacity(0.12)
                            : Color(.systemGray6)
                    )
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Filter chips

    @ViewBuilder
    private func filterItem(
        icon: String,
        label: String,
        type: CardSessionFilter
    ) -> some View {
        Button {
            selectedFilter = type
        } label: {
            VStack {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .bold))
                Text(label)
                    .font(.caption2)
            }
            .foregroundColor(
                selectedFilter == type ? .blue : .gray
            )
            .padding(6)
        }
    }
}
