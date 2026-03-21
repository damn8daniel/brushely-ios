import SwiftUI

/// Minimal dental arch drawn with Canvas. Active zone teeth glow with gradient.
struct ToothMapView: View {
    let activeZone: Int

    var body: some View {
        VStack(spacing: 6) {
            arch(upper: true)
            arch(upper: false).rotation3DEffect(.degrees(180), axis: (1, 0, 0))
        }
        .padding(.vertical, 8)
        .animation(.easeInOut(duration: 0.3), value: activeZone)
    }

    private func arch(upper: Bool) -> some View {
        Canvas { ctx, size in
            let mx = size.width / 2
            let by: CGFloat = upper ? size.height * 0.85 : size.height * 0.15
            let ah: CGFloat = size.height * 0.7
            let aw: CGFloat = size.width * 0.8

            for i in 0..<14 {
                let t = Double(i) / 13.0
                let a = Double.pi * (0.12 + t * 0.76)
                let x = mx + cos(a) * aw / 2
                let y = by - sin(a) * ah

                let zone = toothZone(index: i, upper: upper)
                let active = zone == activeZone || activeZone == (upper ? 6 : 7)

                let s: CGFloat = (i >= 4 && i < 10) ? 9 : 11
                let r = CGRect(x: x - s/2, y: y - s/2, width: s, height: s * 1.15)
                let path = Path(roundedRect: r, cornerRadius: 3)

                if active {
                    // Glow effect
                    ctx.fill(Path(ellipseIn: r.insetBy(dx: -5, dy: -5)), with: .color(.bMint.opacity(0.15)))
                    ctx.fill(path, with: .color(.bMint))
                    // Inner shine
                    let shineRect = CGRect(x: r.minX + 1, y: r.minY + 1, width: r.width - 2, height: r.height * 0.4)
                    ctx.fill(Path(roundedRect: shineRect, cornerRadius: 2), with: .color(.white.opacity(0.2)))
                } else {
                    ctx.fill(path, with: .color(.white.opacity(0.1)))
                }
            }
        }
        .frame(height: 55)
    }

    private func toothZone(index: Int, upper: Bool) -> Int {
        let off = upper ? 0 : 3
        if index < 4 { return off + 2 }
        if index < 10 { return off + 1 }
        return off
    }
}
