import SwiftUI

struct StatusOverlayView: View {
    let status: MotionStatus
    let intensity: Double
    let hz: Double

    @State private var breathe = false
    @State private var appear = false

    var body: some View {
        VStack(spacing: 14) {
            // Organic intensity ring with glow
            ZStack {
                // Outer glow pulse
                Circle()
                    .fill(statusColor.opacity(intensity > 0.5 ? (breathe ? 0.15 : 0.05) : 0.02))
                    .frame(width: 110, height: 110)
                    .blur(radius: 15)

                // Track
                Circle()
                    .stroke(statusColor.opacity(0.1), lineWidth: 8)

                // Fill with gradient
                Circle()
                    .trim(from: 0, to: CGFloat(intensity))
                    .stroke(
                        AngularGradient(
                            colors: [statusColor, statusColor.opacity(0.5), statusGradientEnd, statusColor],
                            center: .center
                        ),
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(response: 0.4, dampingFraction: 0.7), value: intensity)
                    .shadow(color: statusColor.opacity(intensity > 0.5 ? 0.5 : 0.1), radius: 12)

                VStack(spacing: 2) {
                    Text(String(format: "%.1f", hz))
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .contentTransition(.numericText())
                    Text("Hz")
                        .font(.system(size: 10, weight: .medium, design: .rounded))
                        .foregroundStyle(statusColor.opacity(0.7))
                }
                .foregroundStyle(statusColor)
            }
            .frame(width: 80, height: 80)

            // Status label with glass pill
            Text(status.label)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(.white.opacity(0.9))
                .padding(.horizontal, 18)
                .padding(.vertical, 9)
                .background(
                    Capsule()
                        .fill(.ultraThinMaterial)
                        .overlay(
                            Capsule()
                                .stroke(statusColor.opacity(0.2), lineWidth: 1)
                        )
                        .shadow(color: statusColor.opacity(0.1), radius: 8)
                )
        }
        .scaleEffect(appear ? 1 : 0.8)
        .opacity(appear ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.4)) { appear = true }
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) { breathe = true }
        }
        .onChange(of: status) { old, new in
            if new == .correct && old != .correct { Haptic.success() }
            if new == .incorrect && old != .incorrect { Haptic.warn() }
            if new == .handTooFar && old != .handTooFar { Haptic.warn() }
        }
    }

    private var statusColor: Color {
        switch status {
        case .correct: return .bSuccess
        case .incorrect: return .bError
        case .analyzing: return .bWarn
        case .noHand, .idle, .handTooFar: return .bText3
        }
    }

    private var statusGradientEnd: Color {
        switch status {
        case .correct: return .bMint
        case .incorrect: return .bCoral
        case .analyzing: return Color(red: 1.0, green: 0.85, blue: 0.3)
        case .noHand, .idle, .handTooFar: return .bText2
        }
    }
}
