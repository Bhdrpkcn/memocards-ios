import SwiftUI

@main
struct MemoCardsApp: App {

    @StateObject private var nav = NavigationCoordinator()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(nav)
        }
    }
}
