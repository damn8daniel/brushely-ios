import SwiftUI

struct CompletionView: View {
    let percentage: Double
    let duration: TimeInterval
    let correctMovements: Int
    let totalMovements: Int
    let onSave: () -> Void
    let onDismiss: () -> Void

    @State private var ring = false
    @State private var countUp: Double = 0
    @State private var reveal = false
    @State private var showConfetti = false
    @State private var glowPulse = false

    var body: some View {
        ZStack {
            // Deep dark breathing background
            BreathingBackgroundView()

            // Confetti burst for high scores
            if showConfetti && percentage >= 70 {
                ConfettiBurst()
                    .allowsHitTesting(false)
            }

            VStack(spacing: 28) {
                Spacer()

                // Animated grade badge
                ZStack {
                    // Glow rings
                    Circle()
                        .fill(gradeColor.opacity(glowPulse ? 0.15 : 0.05))
                        .frame(width: 130, height: 130)
                        .blur(radius: 20)

                    // Grade text
                    Text(gradeEmoji)
                        .font(.system(size: 56))
                        .scaleEffect(reveal ? 1 : 0.3)
                        .opacity(reveal ? 1 : 0)
                }

                // Score ring with gradient
                ZStack {
                    // Track
                    Circle()
                        .stroke(Color.white.opacity(0.06), lineWidth: 14)
                        .frame(width: 200, height: 200)

                    // Fill ring with gradient
                    Circle()
                        .trim(from: 0, to: ring ? CGFloat(percentage / 100) : 0)
                        .stroke(
                            AngularGradient(
                                colors: [gradeColor, gradeColor.opacity(0.6), gradeAccentColor, gradeColor],
                                center: .center
                            ),
                            style: StrokeStyle(lineWidth: 14, lineCap: .round)
                        )
                        .frame(width: 200, height: 200)
                        .rotationEffect(.degrees(-90))
                        .shadow(color: gradeColor.opacity(0.5), radius: 16)

                    // Score number
                    VStack(spacing: 4) {
                        Text("\(Int(countUp))%")
                            .font(.system(size: 52, weight: .bold, design: .rounded))
                            .monospacedDigit()
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color.bText1, gradeColor.opacity(0.8)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .contentTransition(.numericText())
                        Text(gradeText)
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundStyle(gradeColor)
                            .shadow(color: gradeColor.opacity(0.3), radius: 4)
                    }
                }

                if reveal {
                    // Stats cards
                    HStack(spacing: 12) {
                        statCard(
                            label: "ВРЕМЯ",
                            value: fmtDur,
                            icon: "clock.fill",
                            color: .bViolet
                        )
                        statCard(
                            label: "ТОЧНОСТЬ",
                            value: "\(correctMovements)/\(totalMovements)",
                            icon: "target",
                            color: .bMint
                        )
                    }
                    .padding(.horizontal, 24)
                    .transition(.asymmetric(
                        insertion: .move(edge: .bottom).combined(with: .opacity),
                        removal: .opacity
                    ))

                    Spacer()

                    // Save button with gradient
                    Button { Haptic.success(); onSave() } label: {
                        Text("СОХРАНИТЬ")
                            .font(.system(size: 16, weight: .bold, design: .rounded)).tracking(1)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity).padding(.vertical, 18)
                            .background(
                                Capsule()
                                    .fill(
                                        LinearGradient(
                                            colors: [gradeColor, gradeAccentColor],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .shadow(color: gradeColor.opacity(0.4), radius: 20, y: 8)
                            )
                            .overlay(Capsule().stroke(Color.white.opacity(0.15), lineWidth: 1))
                    }
                    .padding(.horizontal, 32)
                    .transition(.move(edge: .bottom).combined(with: .opacity))

                    Button { onDismiss() } label: {
                        Text("Пропустить")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundStyle(Color.bText2)
                    }
                    .transition(.opacity)
                } else {
                    Spacer()
                }
            }
            .padding(.bottom, 32)
        }
        .onAppear {
            Haptic.heavy()
            withAnimation(.spring(response: 1.5, dampingFraction: 0.8)) { ring = true }
            withAnimation(.easeOut(duration: 1.5)) { countUp = percentage }
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) { glowPulse = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                Haptic.success()
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) { reveal = true }
                showConfetti = true
            }
        }
    }

    // MARK: - Stat Card

    private func statCard(label: String, value: String, icon: String, color: Color) -> some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.12))
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundStyle(color)
            }
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(Color.bText1)
            Text(label)
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .tracking(1)
                .foregroundStyle(Color.bText3)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color.bCard)
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(Color.white.opacity(0.05), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.2), radius: 20, y: 8)
        )
    }

    // MARK: - Grade Helpers

    private var gradeColor: Color {
        switch percentage {
        case 90...100: return .bSuccess
        case 80..<90: return .bMint
        case 70..<80: return Color(red: 0.3, green: 0.7, blue: 1.0)
        case 60..<70: return .bWarn
        default: return .bCoral
        }
    }

    private var gradeAccentColor: Color {
        switch percentage {
        case 90...100: return .bMint
        case 80..<90: return Color(red: 0, green: 0.6, blue: 0.9)
        case 70..<80: return .bViolet
        case 60..<70: return Color(red: 1.0, green: 0.5, blue: 0.0)
        default: return .bError
        }
    }

    private var gradeEmoji: String {
        switch percentage {
        case 90...100: return "A+"
        case 80..<90: return "A"
        case 70..<80: return "B"
        case 60..<70: return "C"
        default: return "D"
        }
    }

    private var gradeText: String {
        switch percentage {
        case 90...100: return "Превосходно"
        case 80..<90: return "Отлично"
        case 70..<80: return "Хорошо"
        case 60..<70: return "Неплохо"
        default: return "Практикуйтесь"
        }
    }

    private var fmtDur: String {
        let m = Int(duration) / 60
        let s = Int(duration) % 60
        return String(format: "%d:%02d", m, s)
    }
}
