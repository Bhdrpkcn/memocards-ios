import SwiftUI

struct StartView: View {

    let languagePair: LanguagePair?
    ///callback for parent to know pair change
    let onLanguagePairChange: (LanguagePair?) -> Void

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
                mainStartFlow
                    .onAppear {
                        // wire callbacks for StartView → parent
                        viewModel.onLanguagePairConfirmed = { pair in
                            onLanguagePairChange(pair)
                        }
                        viewModel.onLanguageReset = {
                            onLanguagePairChange(nil)
                        }

                        // initial sync (app launch with stored pair)
                        syncWithLanguagePair(languagePair)
                    }
                    .onChange(of: languagePair) { newPair in
                        // header changed the pair
                        syncWithLanguagePair(newPair)
                    }

            }
        }
    }
    private func syncWithLanguagePair(_ pair: LanguagePair?) {
        viewModel.applyLanguagePair(pair)

        guard pair != nil else { return }

        Task {
            await viewModel.loadContentForCurrentPair(userId: userId)
        }
    }

    // MARK: - Main step-based layout
    private var mainStartFlow: some View {
        VStack(spacing: 16) {

            MascotAnimationView()
                .frame(height: 220)
                .padding(.top, 8)

            VStack(spacing: 6) {
                Text(currentTitle)
                    .font(.title2.bold())
                    .multilineTextAlignment(.center)

                if let subtitle = currentSubtitle {
                    Text(subtitle)
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
            .padding(.horizontal, 24)

            stepContent

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        //        .background(Color(.systemBackground))
        .background(Color.white.opacity(0.7))
    }

    // MARK: - Step title/subtitle

    private var currentTitle: String {
        switch viewModel.step {
        case .chooseFromLanguage:
            return "Which language do you\nwant to learn from?"
        case .chooseToLanguage:
            return "Which language do you\nwant to learn to?"
        case .chooseContent:
            return "Select what to learn"
        }
    }

    private var currentSubtitle: String? {
        switch viewModel.step {
        case .chooseFromLanguage:
            return nil

        case .chooseToLanguage(let fromCode):
            let fromName = languageName(for: fromCode)
            if let toCode = viewModel.selectedToCode {
                let toName = languageName(for: toCode)
                return "From \(fromName) to \(toName)"
            } else {
                return "From \(fromName)"
            }

        case .chooseContent(let fromCode, let toCode):
            let fromName = languageName(for: fromCode)
            let toName = languageName(for: toCode)
            return "\(fromName) → \(toName)"
        }
    }

    private func languageName(for code: String) -> String {
        viewModel.availableLanguages.first(where: { $0.code == code })?.name
            ?? code.uppercased()
    }

    // MARK: - Step content switch
    @ViewBuilder
    private var stepContent: some View {
        switch viewModel.step {
        case .chooseFromLanguage, .chooseToLanguage:
            VStack(spacing: 12) {
                LanguageSelectionView(
                    step: viewModel.step,
                    availableLanguages: viewModel.availableLanguages,
                    selectedFromCode: viewModel.selectedFromCode,
                    selectedToCode: viewModel.selectedToCode,
                    onSelectFrom: { code in
                        viewModel.selectFromLanguage(code)
                    },
                    onSelectTo: { code in
                        viewModel.selectToLanguage(code)
                    }
                )

                if shouldShowLanguageActions {
                    LanguageSelectionActionsView(
                        onReset: {
                            withAnimation(
                                .spring(
                                    response: 0.25,
                                    dampingFraction: 0.85
                                )
                            ) {
                                viewModel.restartFlow()
                            }
                        },
                        onConfirm: {
                            withAnimation(
                                .spring(
                                    response: 0.25,
                                    dampingFraction: 0.85
                                )
                            ) {
                                viewModel.confirmLanguages()
                            }
                        }
                    )
                    .transition(.opacity.combined(with: .scale))
                }
            }

        case .chooseContent:
            DeckSelectionView(
                easyDecks: viewModel.easyDecks,
                mediumDecks: viewModel.mediumDecks,
                hardDecks: viewModel.hardDecks,
                collections: viewModel.collections,
                errorMessage: viewModel.errorMessage,
                isLoading: viewModel.isLoadingContent,
                selectedDeck: $viewModel.selectedDeck,
                selectedFilter: $viewModel.selectedFilter,
                onStart: {
                    if let deck = viewModel.selectedDeck {
                        activeFilter = viewModel.selectedFilter
                        onStartSession(deck, viewModel.selectedFilter)
                    }
                },
                onChangeLanguages: {
                    viewModel.restartFlow()
                }
            )
        }
    }

    //TODO: Move into a file ?
    // MARK: - Helpers
    private var shouldShowLanguageActions: Bool {
        guard case .chooseToLanguage = viewModel.step else {
            return false
        }
        return viewModel.selectedFromCode != nil && viewModel.selectedToCode != nil
    }
}

// MARK: - Action bar
struct LanguageSelectionActionsView: View {
    let onReset: () -> Void
    let onConfirm: () -> Void

    var body: some View {
        GeometryReader { geo in
            let totalWidth = geo.size.width
            let resetWidth = totalWidth * 0.25
            let okWidth = totalWidth * 0.75

            HStack(spacing: 12) {
                Button {
                    onReset()
                } label: {
                    Text("Reset")
                        .font(.subheadline.weight(.semibold))
                        .frame(width: resetWidth, height: 40)
                        .background(Color(.systemGray5))
                        .foregroundColor(.primary)
                        .cornerRadius(12)
                }

                Button {
                    onConfirm()
                } label: {
                    Text("OK")
                        .font(.headline)
                        .frame(width: okWidth, height: 40)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .frame(height: 44)
        .padding(.top, 8)
        .padding(.horizontal, 24)
    }
}
