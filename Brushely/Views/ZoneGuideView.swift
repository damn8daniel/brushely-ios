import SwiftUI

/// Zone guide card for active brushing HUD — now with living animated illustrations
struct ZoneGuideView: View {
    let zone: BrushingZone
    let zoneProgress: Double
    let stepLabel: String

    @State private var appear = false
    @State private var bounce = false

    var body: some View {
        VStack(spacing: 14) {
            HStack(alignment: .center, spacing: 16) {
                // ANIMATED zone illustration instead of static image
                AnimatedToothView(zone: zone, isActive: true, size: 68)
                    .frame(width: 72, height: 72)
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(Color.bSurface)
                            .overlay(
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .stroke(Color.bMint.opacity(0.2), lineWidth: 1)
                            )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

                VStack(alignment: .leading, spacing: 5) {
                    // Step indicator with glow
                    Text("ШАГ \(stepLabel)")
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .tracking(1.5)
                        .foregroundStyle(Color.bMint)
                        .shadow(color: Color.bMint.opacity(0.3), radius: 4)

                    Text(zone.name)
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)

                    // Motion hint with animated icon
                    HStack(spacing: 6) {
                        Image(systemName: zone.surface == .chewing ? "arrow.left.arrow.right" : "arrow.up.arrow.down")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(Color.bMint.opacity(0.8))
                            .offset(
                                x: zone.surface == .chewing ? (bounce ? -2 : 2) : 0,
                                y: zone.surface != .chewing ? (bounce ? -2 : 2) : 0
                            )
                        Text(zone.motionHint)
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundStyle(Color.bMint.opacity(0.8))
                    }
                }

                Spacer(minLength: 0)
            }

            // Animated progress bar with glow
            GeometryReader { g in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.white.opacity(0.06))

                    Capsule()
                        .fill(LinearGradient.bMintGradient)
                        .frame(width: g.size.width * max(0.02, zoneProgress))
                        .shadow(color: Color.bMint.opacity(0.5), radius: 6, x: 4)
                        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: zoneProgress)
                }
            }
            .frame(height: 4)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [Color.bMint.opacity(0.15), Color.white.opacity(0.05), Color.bViolet.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .shadow(color: Color.bMint.opacity(0.08), radius: 20, y: 8)
        )
        .scaleEffect(appear ? 1 : 0.95)
        .opacity(appear ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) { appear = true }
            withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) { bounce = true }
        }
        .onChange(of: zone.id) { _, _ in
            Haptic.medium()
            appear = false
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) { appear = true }
        }
    }
}
