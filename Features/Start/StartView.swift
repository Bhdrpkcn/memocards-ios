import SwiftUI

struct StartView: View {

    let languagePair: LanguagePair?

    @Binding var isInSession: Bool
    @Binding var activeDeck: Deck?
    @Binding var activeFilter: CardSessionFilter

    let userId: Int

    let onStartSession: (Deck, CardSessionFilter) -> Void

    @StateObject private var viewModel = StartViewModel()

    var body: some View {
        Group {
            if isInSession, let deck = activeDeck {
                CardDeckView(
                    deck: deck,
                    filter: activeFilter,
                    userId: userId
                )
            } else {
                startFlowBody
            }
        }
    }

    // MARK: - Pre-session flow

    @ViewBuilder
    private var startFlowBody: some View {
        switch viewModel.step {
        case .chooseFromLanguage:
            PickerView(
                title: "Which language do you\nwant to learn from?",
                subtitle: nil
            ) {
                languageGrid(disabledCodes: [])
            }

        case .chooseToLanguage(let from):
            PickerView(
                title: "Which language do you\nwant to learn to?",
                subtitle: nil
            ) {
                languageGrid(disabledCodes: [from])
            }

        case .chooseContent(let from, let to):
            PickerView(
                title: "Select what to learn",
                subtitle: "\(from.uppercased()) → \(to.uppercased())"
            ) {
                deckSelectionContent()
                    .task {
                        await viewModel.loadContentForCurrentPair(userId: userId)
                    }
            }
        }
    }

    // MARK: - Language grid

    @ViewBuilder
    private func languageGrid(disabledCodes: [String]) -> some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
            ],
            spacing: 16
        ) {
            ForEach(viewModel.availableLanguages) { option in
                let isDisabled = disabledCodes.contains(option.code)

                Button {
                    guard !isDisabled else { return }

                    switch viewModel.step {
                    case .chooseFromLanguage:
                        viewModel.selectFromLanguage(option.code)
                    case .chooseToLanguage:
                        viewModel.selectToLanguage(option.code)
                    case .chooseContent:
                        break
                    }
                } label: {
                    VStack(spacing: 4) {
                        Text(option.name)
                            .font(.headline)
                        Text(option.code.uppercased())
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, minHeight: 60)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(
                                isDisabled
                                    ? Color(.systemGray5)
                                    : Color(.systemGray6)
                            )
                    )
                    .opacity(isDisabled ? 0.5 : 1.0)
                }
                .buttonStyle(.plain)
                .disabled(isDisabled)
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 16)
    }

    // MARK: - Deck selection UI (grouped word sets + collections)

    @ViewBuilder
    private func deckSelectionContent() -> some View {
        VStack(spacing: 20) {

            if viewModel.isLoadingContent {
                ProgressView("Loading your decks...")
                    .padding(.top, 8)
            }

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {

                    // System word sets
                    if !viewModel.easyDecks.isEmpty {
                        deckSection(
                            title: "Easy Words",
                            subtitle: "Great for warming up",
                            decks: viewModel.easyDecks
                        )
                    }

                    if !viewModel.mediumDecks.isEmpty {
                        deckSection(
                            title: "Medium Words",
                            subtitle: "A bit more challenge",
                            decks: viewModel.mediumDecks
                        )
                    }

                    if !viewModel.hardDecks.isEmpty {
                        deckSection(
                            title: "Hard Words",
                            subtitle: "For serious practice",
                            decks: viewModel.hardDecks
                        )
                    }

                    // User collections
                    if !viewModel.collections.isEmpty {
                        deckSection(
                            title: "Your Collections",
                            subtitle: "Custom decks you saved",
                            decks: viewModel.collections,
                            isCollectionSection: true
                        )
                    }
                }
                .padding(.top, 8)
            }

            if let error = viewModel.errorMessage, !error.isEmpty {
                Text(error)
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
            Button {
                if let deck = viewModel.selectedDeck {
                    activeFilter = viewModel.selectedFilter
                    onStartSession(deck, viewModel.selectedFilter)
                }
            } label: {
                Text("Start")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(viewModel.selectedDeck == nil ? Color.gray : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(14)
                    .padding(.horizontal, 40)
            }
            .disabled(viewModel.selectedDeck == nil)

            Button(role: .cancel) {
                viewModel.restartFlow()
            } label: {
                Text("Change languages")
                    .font(.subheadline)
            }
            .padding(.top, 4)
        }
        .padding(.horizontal, 16)
    }

    // MARK: - Section helper

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
        let isSelected = viewModel.selectedDeck == deck

        Button {
            viewModel.selectedDeck = deck
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

    // MARK: - Filter item

    @ViewBuilder
    private func filterItem(
        icon: String,
        label: String,
        type: CardSessionFilter
    ) -> some View {
        Button {
            viewModel.setFilter(type)
        } label: {
            VStack {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .bold))
                Text(label)
                    .font(.caption2)
            }
            .foregroundColor(
                viewModel.selectedFilter == type ? .blue : .gray
            )
            .padding(6)
        }
    }
}
