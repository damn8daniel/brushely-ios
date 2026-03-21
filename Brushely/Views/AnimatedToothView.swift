import SwiftUI

// MARK: - Animated Zone Illustration
// Replaces static PNGs with living animations showing correct brushing motion

struct AnimatedToothView: View {
    let zone: BrushingZone
    let isActive: Bool
    let size: CGFloat

    @State private var phase: CGFloat = 0

    var body: some View {
        ZStack {
            // Glow backdrop
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            glowColor.opacity(isActive ? 0.25 : 0.08),
                            .clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: size * 0.6
                    )
                )
                .frame(width: size * 1.3, height: size * 1.3)

            // Tooth shape
            Canvas { ctx, canvasSize in
                drawTeeth(ctx: ctx, size: canvasSize, zone: zone, phase: phase, active: isActive)
            }
            .frame(width: size, height: size)

            // Animated brush overlay
            if isActive {
                BrushMotionOverlay(zone: zone, size: size, phase: phase)
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 1.2).repeatForever(autoreverses: true)) {
                phase = 1.0
            }
        }
    }

    private var glowColor: Color {
        switch zone.surface {
        case .outer: return .bMint
        case .chewing: return .bViolet
        case .inner: return Color(red: 0.3, green: 0.7, blue: 1.0)
        }
    }

    // MARK: - Draw Teeth

    private func drawTeeth(ctx: GraphicsContext, size: CGSize, zone: BrushingZone, phase: CGFloat, active: Bool) {
        let mx = size.width / 2
        let my = size.height / 2

        switch zone.surface {
        case .outer:
            drawSideTeeth(ctx: ctx, size: size, mx: mx, my: my, phase: phase, active: active, isUpper: zone.jaw == .upper)
        case .chewing:
            drawChewingTeeth(ctx: ctx, size: size, mx: mx, my: my, phase: phase, active: active)
        case .inner:
            drawSideTeeth(ctx: ctx, size: size, mx: mx, my: my, phase: phase, active: active, isUpper: zone.jaw == .upper)
        }
    }

    private func drawSideTeeth(ctx: GraphicsContext, size: CGSize, mx: CGFloat, my: CGFloat, phase: CGFloat, active: Bool, isUpper: Bool) {
        let toothCount = 4
        let toothW: CGFloat = size.width * 0.14
        let toothH: CGFloat = size.height * 0.35
        let gap: CGFloat = toothW * 0.25
        let totalW = CGFloat(toothCount) * toothW + CGFloat(toothCount - 1) * gap
        let startX = mx - totalW / 2
        let baseY = isUpper ? my + size.height * 0.05 : my - size.height * 0.05

        for i in 0..<toothCount {
            let x = startX + CGFloat(i) * (toothW + gap)
            let isCenter = i == 1 || i == 2

            // Slight wave animation on active teeth
            let waveOffset = active ? sin(Double(phase) * .pi + Double(i) * 0.5) * 2 : 0
            let y = isUpper
                ? baseY - toothH + CGFloat(waveOffset)
                : baseY + CGFloat(waveOffset)

            let rect = CGRect(x: x, y: y, width: toothW, height: isCenter ? toothH * 0.85 : toothH)
            let toothPath = Path(roundedRect: rect, cornerRadius: toothW * 0.3)

            // Tooth body
            let toothColor = active ? Color.white : Color.white.opacity(0.4)
            ctx.fill(toothPath, with: .color(toothColor))

            // Gum line
            let gumY = isUpper ? baseY : baseY
            let gumRect = CGRect(x: x - gap * 0.3, y: gumY - 3, width: toothW + gap * 0.6, height: 6)
            let gumPath = Path(roundedRect: gumRect, cornerRadius: 3)
            ctx.fill(gumPath, with: .color(Color(red: 1.0, green: 0.55, blue: 0.55).opacity(active ? 0.5 : 0.2)))
        }

        // Gum line background
        let gumLineY = isUpper ? baseY : baseY
        let gumLine = Path(roundedRect: CGRect(x: startX - 4, y: gumLineY - 2, width: totalW + 8, height: 4), cornerRadius: 2)
        ctx.fill(gumLine, with: .color(Color(red: 1.0, green: 0.45, blue: 0.50).opacity(active ? 0.35 : 0.15)))
    }

    private func drawChewingTeeth(ctx: GraphicsContext, size: CGSize, mx: CGFloat, my: CGFloat, phase: CGFloat, active: Bool) {
        let toothCount = 3
        let toothW: CGFloat = size.width * 0.22
        let toothH: CGFloat = size.height * 0.22
        let gap: CGFloat = toothW * 0.2
        let totalW = CGFloat(toothCount) * toothW + CGFloat(toothCount - 1) * gap
        let startX = mx - totalW / 2

        for i in 0..<toothCount {
            let x = startX + CGFloat(i) * (toothW + gap)
            let y = my - toothH / 2

            let rect = CGRect(x: x, y: y, width: toothW, height: toothH)
            let toothPath = Path(roundedRect: rect, cornerRadius: toothW * 0.25)

            ctx.fill(toothPath, with: .color(active ? Color.white : Color.white.opacity(0.4)))

            // Chewing ridges
            let ridgeCount = 3
            for r in 0..<ridgeCount {
                let ry = y + toothH * 0.25 + CGFloat(r) * (toothH * 0.2)
                let ridgeRect = CGRect(x: x + toothW * 0.15, y: ry, width: toothW * 0.7, height: 1.5)
                ctx.fill(Path(roundedRect: ridgeRect, cornerRadius: 0.75), with: .color(Color.bMint.opacity(active ? 0.3 : 0.1)))
            }
        }
    }
}

// MARK: - Brush Motion Overlay — Animated brush showing correct movement

struct BrushMotionOverlay: View {
    let zone: BrushingZone
    let size: CGFloat
    let phase: CGFloat

    var body: some View {
        Canvas { ctx, canvasSize in
            let mx = canvasSize.width / 2
            let my = canvasSize.height / 2

            // Brush handle
            let brushLength: CGFloat = size * 0.5
            let brushWidth: CGFloat = size * 0.06

            var offset: CGPoint = .zero
            var angle: Double = 0

            switch zone.surface {
            case .outer:
                // Vertical sweeping motion
                let sweep = (phase - 0.5) * size * 0.25
                offset = CGPoint(x: mx + size * 0.05, y: my + sweep)
                angle = zone.jaw == .upper ? -45 : 45

            case .chewing:
                // Horizontal back-and-forth
                let sweep = (phase - 0.5) * size * 0.3
                offset = CGPoint(x: mx + sweep, y: my - size * 0.02)
                angle = 0

            case .inner:
                let sweep = (phase - 0.5) * size * 0.2
                offset = CGPoint(x: mx, y: my + sweep)
                angle = zone.jaw == .upper ? -60 : 60
            }

            // Draw brush head (bristles)
            let headW: CGFloat = size * 0.12
            let headH: CGFloat = size * 0.05
            let headRect = CGRect(x: offset.x - headW/2, y: offset.y - headH/2, width: headW, height: headH)
            let headPath = Path(roundedRect: headRect, cornerRadius: headH * 0.4)
            ctx.fill(headPath, with: .color(Color.bMint.opacity(0.8)))

            // Brush glow
            let glowRect = headRect.insetBy(dx: -4, dy: -4)
            ctx.fill(Path(ellipseIn: glowRect), with: .color(Color.bMint.opacity(0.2)))

            // Motion trail particles
            let particleCount = 5
            for i in 0..<particleCount {
                let t = CGFloat(i) / CGFloat(particleCount)
                let trailPhase = (phase + t * 0.3).truncatingRemainder(dividingBy: 1.0)
                let alpha = (1 - t) * 0.4

                var px = offset.x
                var py = offset.y

                switch zone.surface {
                case .outer, .inner:
                    py += (trailPhase - 0.5) * 8
                    px += CGFloat.random(in: -3...3)
                case .chewing:
                    px += (trailPhase - 0.5) * 8
                    py += CGFloat.random(in: -3...3)
                }

                let pSize: CGFloat = 3 - t * 2
                let pRect = CGRect(x: px - pSize/2, y: py - pSize/2, width: pSize, height: pSize)
                ctx.fill(Path(ellipseIn: pRect), with: .color(Color.bMint.opacity(alpha)))
            }
        }
        .frame(width: size, height: size)
        .allowsHitTesting(false)
    }
}

// MARK: - Compact Zone Thumbnail (for zone strip)

struct ZoneThumbnailAnimated: View {
    let zone: BrushingZone
    let isCurrent: Bool
    let size: CGFloat

    @State private var pulse = false

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.25, style: .continuous)
                .fill(isCurrent ? Color.bMint.opacity(0.15) : Color.bCard)
                .overlay(
                    RoundedRectangle(cornerRadius: size * 0.25, style: .continuous)
                        .stroke(isCurrent ? Color.bMint.opacity(0.5) : Color.white.opacity(0.05), lineWidth: 1)
                )

            // Mini icon
            Image(systemName: zone.surface == .chewing ? "arrow.left.arrow.right" : "arrow.up.arrow.down")
                .font(.system(size: size * 0.3, weight: .medium))
                .foregroundStyle(isCurrent ? Color.bMint : Color.bText3)
                .offset(y: isCurrent && zone.surface != .chewing ? (pulse ? -2 : 2) : 0)
                .offset(x: isCurrent && zone.surface == .chewing ? (pulse ? -2 : 2) : 0)
        }
        .frame(width: size, height: size)
        .scaleEffect(isCurrent ? 1.1 : 1.0)
        .shadow(color: isCurrent ? Color.bMint.opacity(0.3) : .clear, radius: 8)
        .onAppear {
            if isCurrent {
                withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) {
                    pulse = true
                }
            }
        }
        .animation(.spring(response: 0.35), value: isCurrent)
    }
}
