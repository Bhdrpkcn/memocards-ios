import SwiftUI

struct LearnView: View {

    @StateObject private var vm = LearnViewModel()
    @State private var selectedFilter: CardSessionFilter = .all

    let onStartSession: (Deck, CardSessionFilter) -> Void

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            Text("Select Your Deck")
                .font(.title2.bold())
                .padding(.top, 10)

            Divider()

            if vm.isLoading {
                ProgressView("Loading decks...")
                    .padding(.top, 30)
            }

            if !vm.decks.isEmpty {
                Picker("Deck", selection: $vm.selectedDeck) {
                    ForEach(vm.decks, id: \.id) { deck in
                        Text(deck.name).tag(deck as Deck?)
                    }
                }
                .pickerStyle(.wheel)
                .frame(height: 150)

            }

            if let error = vm.errorMessage {
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
                if let deck = vm.selectedDeck {
                    onStartSession(deck, selectedFilter)

                }
            } label: {
                Text("Start")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(14)
                    .padding(.horizontal, 40)
            }
            .disabled(vm.selectedDeck == nil)

            Spacer()

        }

        .task {
            await vm.loadDecks()
        }
    }

    @ViewBuilder
    private func filterItem(icon: String, label: String, type: CardSessionFilter) -> some View {
        Button {
            selectedFilter = type
        } label: {
            VStack {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .bold))
                Text(label)
                    .font(.caption2)
            }
            .foregroundColor(selectedFilter == type ? .blue : .gray)
            .padding(6)
        }
    }

}
