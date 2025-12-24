import Lottie
import SwiftUI

@MainActor
final class MascotViewModel: ObservableObject {
    enum Mood {
        case idle
        case thinking
        case happy
    }

    @Published var mood: Mood = .idle

    //TODO: extend later: change mood depending on step, errors, etc.
}

struct MascotAnimationView: View {

    @StateObject private var viewModel = MascotViewModel()

    var animationName: String = "thinking"

    var body: some View {
        LottieLoopView(name: animationName)
            .accessibilityHidden(true)
    }
}

struct LottieLoopView: UIViewRepresentable {
    let name: String

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)

        let animationView = LottieAnimationView(name: name)
        animationView.loopMode = .autoReverse
        animationView.contentMode = .scaleAspectFit
        animationView.play()

        animationView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(animationView)

        NSLayoutConstraint.activate([
            animationView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            animationView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            animationView.topAnchor.constraint(equalTo: view.topAnchor),
            animationView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}

