import SwiftUI

struct MainTabView: View {
    @State private var tab = 0
    @Namespace private var ns

    init() { UITabBar.appearance().isHidden = true }

    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch tab {
                case 0: BrushingView()
                case 1: CalendarView()
                default: EmptyView()
                }
            }
            .ignoresSafeArea()

            // Floating glass tab bar with glow
            HStack(spacing: 0) {
                tabItem(idx: 0, icon: "sparkles", label: "Чистка")
                tabItem(idx: 1, icon: "chart.bar.fill", label: "Прогресс")
            }
            .padding(6)
            .background(
                Capsule()
                    .fill(Color.bCard)
                    .overlay(
                        Capsule()
                            .stroke(
                                LinearGradient(
                                    colors: [Color.bMint.opacity(0.1), Color.white.opacity(0.05), Color.bViolet.opacity(0.08)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ),
                                lineWidth: 1
                            )
                    )
                    .shadow(color: Color.black.opacity(0.3), radius: 25, y: 10)
                    .shadow(color: Color.bMint.opacity(0.08), radius: 15, y: -2)
            )
            .padding(.horizontal, 60)
            .padding(.bottom, 16)
        }
    }

    private func tabItem(idx: Int, icon: String, label: String) -> some View {
        Button {
            guard tab != idx else { return }
            Haptic.tick()
            withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) { tab = idx }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                if tab == idx {
                    Text(label)
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                }
            }
            .foregroundStyle(tab == idx ? Color.white : Color.bText3)
            .padding(.vertical, 10)
            .padding(.horizontal, tab == idx ? 18 : 14)
            .background {
                if tab == idx {
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [Color.bMint, Color(red: 0.00, green: 0.65, blue: 0.80)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .shadow(color: Color.bMint.opacity(0.35), radius: 10, y: 3)
                        .matchedGeometryEffect(id: "pill", in: ns)
                }
            }
        }
        .buttonStyle(.plain)
    }
}
