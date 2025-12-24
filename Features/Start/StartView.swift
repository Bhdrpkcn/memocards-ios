import SwiftUI

struct StartView: View {

    @Binding var isInSession: Bool
    @Binding var activeDeck: Deck?
    @Binding var activeFilter: CardSessionFilter

    let userId: Int
    let onStartSession: (Deck, CardSessionFilter) -> Void
    let onEndSession: () -> Void
    let onOpenLibrary: () -> Void

    @StateObject private var viewModel = StartViewModel()

    @State private var languagePair: LanguagePair?
    @State private var isLanguageSheetPresented = false
    @State private var sheetInitialPair: LanguagePair?

    var body: some View {
        VStack(spacing: 0) {
            HeaderView(
                isInSession: $isInSession,
                languagePair: languagePair,
                onLanguageTap: handleLanguageTap,
                onBackFromSession: {
                    onEndSession()
                },
                onDecksTap: {
                    onOpenLibrary()
                }
            )

            Group {
                if isInSession, let deck = activeDeck {
                    CardDeckView(
                        deck: deck,
                        filter: activeFilter,
                        userId: userId
                    )
                } else {
                    mainStartFlow
                        .onAppear(perform: setupOnAppear)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .ignoresSafeArea(.keyboard)
        .sheet(isPresented: $isLanguageSheetPresented) {
            languageSheet
        }
        .task {
            await viewModel.loadLanguageOptions()
        }
    }

    // MARK: - First-time setup
    private func setupOnAppear() {
        viewModel.onLanguagePairConfirmed = { pair in
            languagePair = pair

            if isInSession {
                onEndSession()
            }

            Task {
                await viewModel.loadContentForCurrentPair(userId: userId)
            }
        }

        viewModel.onLanguageReset = {
            languagePair = nil

            if isInSession {
                onEndSession()
            }
        }

        if languagePair == nil {
            let stored = LanguagePreferenceStore.load()
            languagePair = stored
            viewModel.applyLanguagePair(stored)

            if stored != nil {
                Task {
                    await viewModel.loadContentForCurrentPair(userId: userId)
                }
            }
        }
    }

    // MARK: - Main step-based layout
    private var mainStartFlow: some View {
        VStack(spacing: 0) {

            MascotAnimationView()
                .frame(height: 220)
                .padding(.vertical, -20)

            Text(currentTitle)
                .font(.title2.bold())
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
                .padding(.bottom, 4)

            stepContent

        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
            return "Select a deck to learn"
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

    private var shouldShowLanguageActions: Bool {
        guard case .chooseToLanguage = viewModel.step else {
            return false
        }
        return viewModel.selectedFromCode != nil && viewModel.selectedToCode != nil
    }

    // MARK: - Header actions
    private func handleLanguageTap() {
        guard let currentPair = languagePair else { return }

        sheetInitialPair = currentPair
        viewModel.startLanguageChangeFlow(currentPair: currentPair)
        isLanguageSheetPresented = true
    }

    // MARK: - Language sheet
    private var languageSheet: some View {
        NavigationView {
            VStack(spacing: 12) {
                Text("Choose languages")
                    .font(.headline)
                    .padding(.top, 12)

                Text("Tap once to select source and target languages.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)

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

                LanguageSelectionActionsView(
                    onReset: {
                        viewModel.restartFlow()
                        isLanguageSheetPresented = false
                    },
                    onConfirm: {
                        viewModel.confirmLanguages()
                        isLanguageSheetPresented = false
                    }
                )

                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        viewModel.applyLanguagePair(sheetInitialPair)
                        isLanguageSheetPresented = false
                    }
                }
            }
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
}
