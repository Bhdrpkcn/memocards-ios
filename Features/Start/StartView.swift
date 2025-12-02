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
                        await viewModel.loadDecksForCurrentPair()
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

    // MARK: - Deck selection UI (merged LearnView logic)
    @ViewBuilder
    private func deckSelectionContent() -> some View {
        VStack(spacing: 20) {

            if viewModel.isLoadingContent {
                ProgressView("Loading decks...")
                    .padding(.top, 30)
            }

            if !viewModel.decks.isEmpty {
                Picker("Deck", selection: $viewModel.selectedDeck) {
                    ForEach(viewModel.decks, id: \.id) { deck in
                        Text(deck.name).tag(deck as Deck?)
                    }
                }
                .pickerStyle(.wheel)
                .frame(height: 150)
            }

            if let error = viewModel.errorMessage, !error.isEmpty {
                Text(error)
                    .foregroundColor(.red)
            }

            HStack(spacing: 22) {
                filterItem(icon: "circle.grid.3x3", label: "All", type: .all)
                filterItem(icon: "checkmark.seal.fill", label: "Known", type: .known)
                filterItem(icon: "arrow.triangle.2.circlepath", label: "Review", type: .review)
            }
            .padding(.top, 12)

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
