import SwiftUI

struct LearnView: View {

    @StateObject private var vm = LearnViewModel()
    let onStartSession: (Deck) -> Void

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

            Button {
                if let deck = vm.selectedDeck {
                    onStartSession(deck)
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
}
