import SwiftUI

struct CardStack<Top: View, Second: View, Third: View>: View {

    let showSecond: Bool
    let showThird: Bool

    @ViewBuilder let third: () -> Third
    @ViewBuilder let second: () -> Second
    @ViewBuilder let top: () -> Top

    var body: some View {
        ZStack {
            if showThird {
                third()
                    .scaleEffect(0.92)
                    .offset(y: 28)
                    .rotationEffect(.degrees(6))
                    .opacity(0.8)
                    .allowsHitTesting(false)
            }

            if showSecond {
                second()
                    .scaleEffect(0.96)
                    .offset(y: 14)
                    .rotationEffect(.degrees(-6))
                    .opacity(0.9)
                    .allowsHitTesting(false)
            }

            top()
        }
    }
}
