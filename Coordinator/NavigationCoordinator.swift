import Foundation
import SwiftUI

@MainActor
final class NavigationCoordinator: ObservableObject {

    @Published private(set) var route: Route = .home

    func goHome() { set(.home) }
    func reset() { set(.home) }

    func openLibrary() { set(.library) }
    func openProfile() { set(.profile) }

    private func set(_ newRoute: Route) {
        guard route != newRoute else { return }
        route = newRoute
    }
}

extension NavigationCoordinator {

    /// Generic helper: create a Binding<Bool> for a given target route.
    func binding(for target: Route, open: @escaping () -> Void) -> Binding<Bool> {
        Binding(
            get: { self.route == target },
            set: { newValue in
                let isActive = (self.route == target)
                guard newValue != isActive else { return }
                if newValue {
                    open()
                } else if isActive {
                    self.reset()
                }
            }
        )
    }

    var isLibraryActive: Binding<Bool> {
        binding(for: .library, open: openLibrary)
    }

    var isProfileActive: Binding<Bool> {
        binding(for: .profile, open: openProfile)
    }
}
