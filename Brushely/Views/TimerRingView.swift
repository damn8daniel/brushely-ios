import SwiftUI

struct TimerRingView: View {
    let progress: Double
    let timeString: String

    var body: some View {
        ZStack {
            // Track
            Circle()
                .stroke(Color.white.opacity(0.06), lineWidth: 5)

            // Progress fill with gradient
            Circle()
                .trim(from: 0, to: CGFloat(progress))
                .stroke(
                    AngularGradient(
                        colors: [Color.bMint, Color(red: 0, green: 0.6, blue: 0.9), Color.bMint],
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: 5, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .shadow(color: .bMint.opacity(0.4), radius: 8)
                .animation(.linear(duration: 0.15), value: progress)

            // Time text
            Text(timeString)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(.white)
        }
        .frame(width: 56, height: 56)
    }
}
