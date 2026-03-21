import SwiftUI

// MARK: - Breathing Background — Organic gradient that slowly shifts and pulses

struct BreathingBackgroundView: View {
    @State private var phase: CGFloat = 0
    @State private var breathe = false

    var body: some View {
        ZStack {
            // Base deep dark
            Color.bBackground

            // Animated gradient orbs
            Canvas { ctx, size in
                // Orb 1 — top-left mint
                let orb1Center = CGPoint(
                    x: size.width * (0.2 + sin(Double(phase) * .pi * 2) * 0.1),
                    y: size.height * (0.15 + cos(Double(phase) * .pi * 2) * 0.05)
                )
                let orb1 = Path(ellipseIn: CGRect(
                    x: orb1Center.x - size.width * 0.4,
                    y: orb1Center.y - size.width * 0.4,
                    width: size.width * 0.8,
                    height: size.width * 0.8
                ))
                ctx.fill(orb1, with: .color(Color(red: 0.00, green: 0.35, blue: 0.45).opacity(0.15)))

                // Orb 2 — bottom-right violet
                let orb2Center = CGPoint(
                    x: size.width * (0.8 - sin(Double(phase) * .pi * 2 + 1) * 0.08),
                    y: size.height * (0.85 + cos(Double(phase) * .pi * 2 + 1) * 0.05)
                )
                let orb2 = Path(ellipseIn: CGRect(
                    x: orb2Center.x - size.width * 0.35,
                    y: orb2Center.y - size.width * 0.35,
                    width: size.width * 0.7,
                    height: size.width * 0.7
                ))
                ctx.fill(orb2, with: .color(Color(red: 0.20, green: 0.08, blue: 0.35).opacity(0.12)))

                // Orb 3 — center glow
                let orb3Radius = size.width * (0.25 + (breathe ? 0.05 : 0))
                let orb3 = Path(ellipseIn: CGRect(
                    x: size.width / 2 - orb3Radius,
                    y: size.height * 0.4 - orb3Radius,
                    width: orb3Radius * 2,
                    height: orb3Radius * 2
                ))
                ctx.fill(orb3, with: .color(Color.bMint.opacity(0.04)))
            }
            .blur(radius: 60)

            // Subtle noise texture
            Canvas { ctx, size in
                for _ in 0..<80 {
                    let x = CGFloat.random(in: 0...size.width)
                    let y = CGFloat.random(in: 0...size.height)
                    let s: CGFloat = CGFloat.random(in: 0.5...1.5)
                    let dot = Path(ellipseIn: CGRect(x: x, y: y, width: s, height: s))
                    ctx.fill(dot, with: .color(Color.white.opacity(CGFloat.random(in: 0.01...0.03))))
                }
            }
        }
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.linear(duration: 12).repeatForever(autoreverses: false)) {
                phase = 1.0
            }
            withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) {
                breathe = true
            }
        }
    }
}

// MARK: - Floating Orb — Reusable glowing circle

struct FloatingOrb: View {
    let color: Color
    let size: CGFloat
    let delay: Double

    @State private var floating = false

    var body: some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: [color.opacity(0.3), color.opacity(0.05), .clear],
                    center: .center,
                    startRadius: 0,
                    endRadius: size / 2
                )
            )
            .frame(width: size, height: size)
            .offset(y: floating ? -8 : 8)
            .blur(radius: size * 0.15)
            .onAppear {
                withAnimation(.easeInOut(duration: 3 + delay).repeatForever(autoreverses: true)) {
                    floating = true
                }
            }
    }
}

// MARK: - Pulse Ring — Expanding ring animation

struct PulseRing: View {
    let color: Color
    let lineWidth: CGFloat

    @State private var scale: CGFloat = 0.8
    @State private var opacity: Double = 0.6

    var body: some View {
        Circle()
            .stroke(color, lineWidth: lineWidth)
            .scaleEffect(scale)
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeOut(duration: 2).repeatForever(autoreverses: false)) {
                    scale = 1.5
                    opacity = 0
                }
            }
    }
}
