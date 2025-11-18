import SwiftUI

struct LearnView: View {

    @StateObject private var vm = LearnViewModel()
    @State private var goToSession = false

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            // MARK: - Title
            Text("Select Your Deck")
                .font(.title2.bold())
                .padding(.top, 10)

            // MARK: - Loading State
            if vm.isLoading {
                ProgressView("Loading decks...")
                    .padding(.top, 30)
            }

            // MARK: - Deck Picker
            if !vm.decks.isEmpty {
                Picker("Deck", selection: $vm.selectedDeck) {
                    ForEach(vm.decks, id: \.id) { deck in
                        Text(deck.name).tag(deck as Deck?)
                    }
                }
                .pickerStyle(.wheel)
                .frame(height: 150)
                .padding(.horizontal)

            }

            // MARK: - Error
            if let error = vm.errorMessage {
                Text(error)
                    .foregroundColor(.red)
            }

            // MARK: - Start Button
            Button {
                goToSession = true
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
            .padding(.top, 20)
            .disabled(vm.selectedDeck == nil)

            Spacer()

        }

        .task {
            await vm.loadDecks()
        }
        .navigationDestination(isPresented: $goToSession) {
            if let deck = vm.selectedDeck {
                CardDeckView(deck: deck)
            }
        }
    }
}
