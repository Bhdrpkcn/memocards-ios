import SwiftUI

struct CardDeckView: View {

    let deck: Deck
    let filter: CardSessionFilter
    let userId: Int

    @StateObject private var vm: CardDeckViewModel

    @State private var isFlipped = false
    @State private var dragOffset: CGSize = .zero

    @State private var pendingCardToSave: MemoCard?
    @State private var newDeckName: String = ""

    @State private var showDeckChoiceOverlay = false
    @State private var showCustomDeckSheet = false
    @State private var isSavingToDeck = false
    @State private var sheetErrorMessage: String?

    init(deck: Deck, filter: CardSessionFilter, userId: Int) {
        self.deck = deck
        self.filter = filter
        self.userId = userId
        _vm = StateObject(
            wrappedValue: CardDeckViewModel(
                deck: deck,
                filter: filter,
                userId: userId
            )
        )
    }

    var body: some View {
        GeometryReader { geo in
            let cardAreaHeight = geo.size.height * 0.70

            ZStack {
                VStack(spacing: 16) {

                    Spacer()

                    // MARK: - Deck header
                    VStack(spacing: 4) {
                        Text(deck.name)
                            .font(.title2.bold())
                        if let description = deck.description {
                            Text(description)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        Text(sessionInfoText)
                            .font(.caption)
                            .foregroundStyle(.secondary)

                    }
                    .padding(.top, 12)

                    Divider()

                    // MARK: - Body
                    ZStack {
                        if vm.isLoading {
                            ProgressView("Loading cards…")
                        } else if let top = vm.topCard {
                            cardStack(topCard: top, height: cardAreaHeight)
                        } else {
                            VStack(spacing: 12) {
                                Text("No more cards 🎉")
                                    .font(.title3.bold())
                                Text("You’ve finished this deck.")
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: cardAreaHeight)

                    Spacer()

                    Text("Swipe right = know, left = review, down = save to a deck")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .padding(.bottom, 8)
                        .multilineTextAlignment(.center)
                        .allowsHitTesting(false)
                }
                .padding(.horizontal)

                if showDeckChoiceOverlay {
                    deckChoiceOverlay()
                }
            }
            .task {
                await vm.loadCards()
                await vm.loadCustomDecksIfNeeded()
            }
            .sheet(isPresented: $showCustomDeckSheet) {
                CustomDeckSheet(
                    vm: vm,
                    pendingCard: $pendingCardToSave,
                    isPresented: $showCustomDeckSheet,
                    newDeckName: $newDeckName,
                    isSavingToDeck: $isSavingToDeck,
                    sheetErrorMessage: $sheetErrorMessage
                )
            }
        }
    }

    private var sessionInfoText: String {
        let count = vm.cards.count

        let base =
            count == 1
            ? "1 card in this session"
            : "\(count) cards in this session"

        switch filter {
        case .all:
            return base + " · All"
        case .known:
            return base + " · Known"
        case .review:
            return base + " · Review"
        }
    }

    // MARK: - Card stack
    private func cardStack(topCard: MemoCard, height: CGFloat) -> some View {
        CardStack(
            showSecond: vm.secondCard != nil,
            showThird: vm.thirdCard != nil
        ) {
            if let third = vm.thirdCard {
                WordCardView(card: third, isFlipped: .constant(false), height: height)
            } else {
                EmptyView()
            }
        } second: {
            if let second = vm.secondCard {
                WordCardView(card: second, isFlipped: .constant(false), height: height)
            } else {
                EmptyView()
            }
        } top: {
            WordCardView(card: topCard, isFlipped: $isFlipped, height: height)
                .offset(dragOffset)
                .rotationEffect(.degrees(Double(dragOffset.width / 15)))
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            dragOffset = value.translation
                        }
                        .onEnded { value in
                            handleDragEnd(translation: value.translation)
                        }
                )
                .onTapGesture {
                    withAnimation {
                        isFlipped.toggle()
                    }
                }
                .animation(.spring(), value: dragOffset)
                .overlay(alignment: .topTrailing) {
                    if dragOffset.width > 0 {
                        swipeLabel(
                            text: "I understand",
                            color: AppTheme.Colors.success,
                            alignment: .trailing
                        )
                        .opacity(min(Double(dragOffset.width / 120), 1.0))
                        .padding(.top, 24)
                        .padding(.trailing, 24)
                    }
                }
                .overlay(alignment: .topLeading) {
                    if dragOffset.width < 0 {
                        swipeLabel(
                            text: "Review later",
                            color: AppTheme.Colors.error,
                            alignment: .leading
                        )
                        .opacity(min(Double(-dragOffset.width / 120), 1.0))
                        .padding(.top, 24)
                        .padding(.leading, 24)
                    }
                }
                .overlay(alignment: .bottom) {
                    if dragOffset.height > 0 {
                        swipeLabel(
                            text: "Save to Deck",
                            color: AppTheme.Colors.progress,
                            alignment: .center
                        )
                        .opacity(min(Double(dragOffset.height / 120), 1.0))
                        .padding(.bottom, 24)
                    }
                }
        }
    }

    // MARK: - Drag resolution
    private func handleDragEnd(translation: CGSize) {
        let horizontal = translation.width
        let vertical = translation.height
        let threshold: CGFloat = 100

        if abs(vertical) > abs(horizontal), vertical > threshold {
            handleSwipeDown()
        } else if horizontal > threshold {
            handleSwipeRight()
        } else if horizontal < -threshold {
            handleSwipeLeft()
        } else {
            withAnimation(.spring()) {
                dragOffset = .zero
            }
        }
    }

    private func handleSwipeRight() {
        guard let card = vm.topCard else {
            dragOffset = .zero
            return
        }

        withAnimation(.spring()) {
            dragOffset = CGSize(width: 500, height: 0)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            isFlipped = false
            dragOffset = .zero
            vm.markKnown(card)
        }
    }

    private func handleSwipeLeft() {
        guard let card = vm.topCard else {
            dragOffset = .zero
            return
        }

        withAnimation(.spring()) {
            dragOffset = CGSize(width: -500, height: 0)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            isFlipped = false
            dragOffset = .zero
            vm.markReview(card)
        }
    }

    private func handleSwipeDown() {
        guard let card = vm.topCard else {
            dragOffset = .zero
            return
        }

        withAnimation(.spring()) {
            dragOffset = CGSize(width: 0, height: 500)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            isFlipped = false
            dragOffset = .zero
            pendingCardToSave = card
            showDeckChoiceOverlay = true
        }
    }

    // MARK: - Deck choice overlay
    @ViewBuilder
    private func deckChoiceOverlay() -> some View {
        ZStack {
            AppTheme.Colors.overlayBackground
                .ignoresSafeArea()
                .onTapGesture {
                    cancelDeckChoice()
                }

            VStack(spacing: 16) {
                VStack(spacing: 8) {
                    Text("Save to Deck")
                        .font(.headline)
                    Text("Choose how you want to save this card.")
                        .font(.caption)
                        .foregroundColor(AppTheme.Colors.textSecondary)
                }
                .padding(.bottom, 4)

                Button {
                    openSheetForAddToExisting()
                } label: {
                    Text("Add to a Deck")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(vm.customDecks.isEmpty ? AppTheme.Colors.disabled : AppTheme.Colors.progress)
                        .foregroundColor(AppTheme.Colors.textPrimary)
                        .cornerRadius(14)
                }
                .disabled(vm.customDecks.isEmpty)

                Button {
                    openSheetForCreateDeck()
                } label: {
                    Text("Create a Deck to Add")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppTheme.Colors.success)
                        .foregroundColor(AppTheme.Colors.textPrimary)
                        .cornerRadius(14)
                }

                Button {
                    cancelDeckChoice()
                } label: {
                    Text("Cancel")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white.opacity(0.9))
                        .foregroundColor(AppTheme.Colors.error)
                        .cornerRadius(14)
                }
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(AppTheme.Colors.screenSecBackground)
            )
            .padding(.horizontal, 32)
        }
        .transition(.opacity.combined(with: .scale))
    }

    private func openSheetForAddToExisting() {
        guard pendingCardToSave != nil else {
            showDeckChoiceOverlay = false
            return
        }
        showDeckChoiceOverlay = false
        showCustomDeckSheet = true
    }

    private func openSheetForCreateDeck() {
        guard pendingCardToSave != nil else {
            showDeckChoiceOverlay = false
            return
        }
        newDeckName = ""
        showDeckChoiceOverlay = false
        showCustomDeckSheet = true
    }

    private func cancelDeckChoice() {
        showDeckChoiceOverlay = false
        pendingCardToSave = nil
    }

    // MARK: - Swipe label helper
    private func swipeLabel(text: String, color: Color, alignment: HorizontalAlignment) -> some View
    {
        Text(text)
            .font(.title2.bold())
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(color, lineWidth: 2)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.white.opacity(0.85))
                    )
            )
            .foregroundColor(color)
            .rotationEffect(rotationAngle(for: alignment))
    }

    private func rotationAngle(for alignment: HorizontalAlignment) -> Angle {
        switch alignment {
        case .leading:
            return .degrees(-12)
        case .trailing:
            return .degrees(12)
        default:
            return .degrees(0)
        }
    }
}

//TODO: Move this customdecksheet to seperared view ?
private struct CustomDeckSheet: View {

    @ObservedObject var vm: CardDeckViewModel

    @Binding var pendingCard: MemoCard?
    @Binding var isPresented: Bool
    @Binding var newDeckName: String
    @Binding var isSavingToDeck: Bool
    @Binding var sheetErrorMessage: String?

    var body: some View {
        NavigationView {
            List {
                if vm.isLoadingCustomDecks {
                    Section {
                        HStack {
                            ProgressView()
                            Text("Loading custom decks…")
                        }
                    }
                } else {
                    if !vm.customDecks.isEmpty {
                        Section("Choose a deck") {
                            ForEach(vm.customDecks, id: \.id) { deck in
                                Button {
                                    addToExisting(deck: deck)
                                } label: {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(deck.name)
                                                .font(.headline)
                                            //TODO: Returning nil
                                            Text("\(String(describing: deck.cardCount)) cards")
                                                .font(.caption)
                                                .foregroundColor(AppTheme.Colors.textSecondary)
                                        }
                                        Spacer()
                                    }
                                }
                                .disabled(isSavingToDeck || pendingCard == nil)
                                .swipeActions {
                                    Button(role: .destructive) {
                                        Task {
                                            await deleteDeck(deck)
                                        }
                                    } label: {
                                        Text("Delete")
                                    }
                                }
                            }
                        }
                    }

                    Section("Create new deck") {
                        TextField("Deck name", text: $newDeckName)
                        Button {
                            createAndSave()
                        } label: {
                            if isSavingToDeck {
                                ProgressView()
                            } else {
                                Text("Create & Save")
                            }
                        }
                        .disabled(
                            isSavingToDeck || pendingCard == nil
                                || newDeckName.trimmingCharacters(in: .whitespacesAndNewlines)
                                    .isEmpty
                        )
                    }

                    if let error = sheetErrorMessage {
                        Section {
                            Text(error)
                                .foregroundColor(AppTheme.Colors.error)
                        }
                    }
                }
            }
            .task {
                await vm.loadCustomDecksIfNeeded()
            }
            .navigationTitle("Save to custom deck")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
            }
        }
    }

    private func addToExisting(deck: Deck) {
        guard let card = pendingCard else { return }
        isSavingToDeck = true
        sheetErrorMessage = nil

        Task {
            do {
                try await vm.addCard(card, to: deck)
                pendingCard = nil
                isPresented = false
            } catch {
                sheetErrorMessage = error.localizedDescription
            }
            isSavingToDeck = false
        }
    }

    private func createAndSave() {
        guard let card = pendingCard else { return }
        let name = newDeckName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else { return }

        isSavingToDeck = true
        sheetErrorMessage = nil

        Task {
            do {
                try await vm.createCustomDeckAndAddCard(name: name, card: card)
                pendingCard = nil
                isPresented = false
                newDeckName = ""
            } catch {
                sheetErrorMessage = error.localizedDescription
            }
            isSavingToDeck = false
        }
    }

    private func deleteDeck(_ deck: Deck) async {
        isSavingToDeck = true
        sheetErrorMessage = nil
        do {
            try await vm.deleteCustomDeck(deck)
        } catch {
            sheetErrorMessage = error.localizedDescription
        }
        isSavingToDeck = false
    }
}
