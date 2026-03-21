import SwiftUI

// MARK: - Celebration Particle System

struct ParticleEffectView: View {
    let color: Color
    let particleCount: Int
    let isActive: Bool

    @State private var particles: [Particle] = []
    @State private var timer: Timer?

    struct Particle: Identifiable {
        let id = UUID()
        var x: CGFloat
        var y: CGFloat
        var size: CGFloat
        var opacity: Double
        var velocityX: CGFloat
        var velocityY: CGFloat
        var lifetime: Double
        var age: Double = 0
        var color: Color
    }

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0/30)) { timeline in
            Canvas { ctx, size in
                for particle in particles {
                    let progress = particle.age / particle.lifetime
                    let alpha = (1 - progress) * particle.opacity
                    let currentSize = particle.size * (1 - progress * 0.5)

                    let rect = CGRect(
                        x: particle.x - currentSize / 2,
                        y: particle.y - currentSize / 2,
                        width: currentSize,
                        height: currentSize
                    )

                    // Glow
                    let glowRect = rect.insetBy(dx: -currentSize * 0.5, dy: -currentSize * 0.5)
                    ctx.fill(Path(ellipseIn: glowRect), with: .color(particle.color.opacity(alpha * 0.3)))
                    ctx.fill(Path(ellipseIn: rect), with: .color(particle.color.opacity(alpha)))
                }
            }
        }
        .onChange(of: isActive) { _, active in
            if active { startEmitting() } else { stopEmitting() }
        }
        .onAppear {
            if isActive { startEmitting() }
        }
        .onDisappear { stopEmitting() }
    }

    private func startEmitting() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0/20, repeats: true) { _ in
            // Add new particles
            if particles.count < particleCount {
                let newParticle = Particle(
                    x: CGFloat.random(in: 50...300),
                    y: CGFloat.random(in: 200...500),
                    size: CGFloat.random(in: 3...8),
                    opacity: Double.random(in: 0.4...0.9),
                    velocityX: CGFloat.random(in: -2...2),
                    velocityY: CGFloat.random(in: -4...-1),
                    lifetime: Double.random(in: 1.5...3.0),
                    color: [color, .bMint, .bViolet, .white].randomElement()!
                )
                particles.append(newParticle)
            }

            // Update existing
            for i in particles.indices {
                particles[i].x += particles[i].velocityX
                particles[i].y += particles[i].velocityY
                particles[i].age += 1.0/20
            }

            // Remove dead
            particles.removeAll { $0.age >= $0.lifetime }
        }
    }

    private func stopEmitting() {
        timer?.invalidate()
        timer = nil
    }
}

// MARK: - Sparkle Effect — Small burst of sparkles

struct SparkleView: View {
    @State private var sparkles: [(id: UUID, x: CGFloat, y: CGFloat, delay: Double)] = []
    @State private var visible = false

    var body: some View {
        ZStack {
            ForEach(sparkles, id: \.id) { sparkle in
                StarShape()
                    .fill(Color.bMint)
                    .frame(width: 8, height: 8)
                    .position(x: sparkle.x, y: sparkle.y)
                    .scaleEffect(visible ? 1 : 0)
                    .opacity(visible ? 0 : 1)
                    .animation(
                        .easeOut(duration: 1.2).delay(sparkle.delay),
                        value: visible
                    )
            }
        }
        .onAppear {
            sparkles = (0..<12).map { _ in
                (
                    id: UUID(),
                    x: CGFloat.random(in: 30...330),
                    y: CGFloat.random(in: 100...600),
                    delay: Double.random(in: 0...0.6)
                )
            }
            withAnimation { visible = true }
        }
    }
}

// MARK: - Star Shape

struct StarShape: Shape {
    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let outerRadius = min(rect.width, rect.height) / 2
        let innerRadius = outerRadius * 0.4
        let points = 4

        var path = Path()
        for i in 0..<points * 2 {
            let angle = Double(i) * .pi / Double(points) - .pi / 2
            let radius = i % 2 == 0 ? outerRadius : innerRadius
            let point = CGPoint(
                x: center.x + cos(angle) * radius,
                y: center.y + sin(angle) * radius
            )
            if i == 0 { path.move(to: point) } else { path.addLine(to: point) }
        }
        path.closeSubpath()
        return path
    }
}

// MARK: - Confetti Burst

struct ConfettiBurst: View {
    let colors: [Color] = [.bMint, .bViolet, .bCoral, .bSuccess, .bWarn, .white]

    @State private var confetti: [(id: UUID, x: CGFloat, y: CGFloat, rotation: Double, color: Color)] = []
    @State private var launched = false

    var body: some View {
        ZStack {
            ForEach(confetti, id: \.id) { piece in
                RoundedRectangle(cornerRadius: 2)
                    .fill(piece.color)
                    .frame(width: CGFloat.random(in: 4...8), height: CGFloat.random(in: 8...14))
                    .rotationEffect(.degrees(launched ? piece.rotation + 360 : piece.rotation))
                    .position(x: launched ? piece.x : 195, y: launched ? piece.y : 300)
                    .opacity(launched ? 0 : 1)
            }
        }
        .onAppear {
            confetti = (0..<30).map { _ in
                (
                    id: UUID(),
                    x: CGFloat.random(in: -30...420),
                    y: CGFloat.random(in: -100...200),
                    rotation: Double.random(in: 0...360),
                    color: colors.randomElement()!
                )
            }
            withAnimation(.easeOut(duration: 2.5)) { launched = true }
        }
    }
}
