import SwiftUI

struct SaveToCollectionSheet: View {
    @ObservedObject var vm: CardDeckViewModel
    @Binding var pendingCard: MemoCard?
    @Binding var isPresented: Bool

    // View-Local State (for typing performance issue)
    @State private var newDeckName: String = ""
    @State private var isSaving: Bool = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            List {
                // Create
                Section {
                    HStack {
                        TextField("New deck name", text: $newDeckName)
                            .submitLabel(.done)
                        
                        if isSaving {
                            ProgressView().padding(.leading, 8)
                        } else {
                            Button("Create") {
                                performAction {
                                    try await vm.createCustomDeckAndAddCard(name: newDeckName, card: $0)
                                }
                            }
                            .disabled(newDeckName.trimmingCharacters(in: .whitespaces).isEmpty)
                            .font(.subheadline.bold())
                            .foregroundColor(AppTheme.Colors.primary)
                            .buttonStyle(.borderless)
                        }
                    }
                } header: { Text("Create New") } footer: {
                    if let error = errorMessage {
                        Text(error).foregroundColor(AppTheme.Colors.error)
                    }
                }

                // Existing
                Section("Your Collections") {
                    if vm.isLoadingCustomDecks {
                        HStack { ProgressView(); Text("Loading...").foregroundColor(.secondary) }
                    } else if vm.customDecks.isEmpty {
                        Text("No collections yet").foregroundColor(.secondary)
                    } else {
                        ForEach(vm.customDecks, id: \.id) { deck in
                            Button {
                                performAction { try await vm.addCard($0, to: deck) }
                            } label: {
                                collectionRow(deck)
                            }
                            .disabled(isSaving)
                        }
                        .onDelete { indexSet in
                            indexSet.forEach { idx in
                                let deck = vm.customDecks[idx]
                                Task { try? await vm.deleteCustomDeck(deck) }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Save Card")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { isPresented = false; pendingCard = nil }
                }
            }
            .task { await vm.loadCustomDecksIfNeeded() }
        }
    }
    
    // MARK: - Clean Action Handler
    private func performAction(_ action: @escaping (MemoCard) async throws -> Void) {
        guard let card = pendingCard else { return }
        isSaving = true
        errorMessage = nil
        
        Task {
            do {
                try await action(card)
                isPresented = false
                pendingCard = nil
            } catch {
                errorMessage = error.localizedDescription
            }
            isSaving = false
        }
    }
    
    private func collectionRow(_ deck: Deck) -> some View {
        HStack {
            VStack(alignment: .leading) {
                Text(deck.name).font(.headline).foregroundColor(AppTheme.Colors.textPrimary)
                Text("\(deck.cardCount ?? 0) cards").font(.caption).foregroundColor(.secondary)
            }
            Spacer()
            Image(systemName: "plus.circle").font(.title3).foregroundColor(AppTheme.Colors.primary)
        }
    }
}
