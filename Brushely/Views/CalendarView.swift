import SwiftUI
import SwiftData

struct CalendarView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \BrushingSession.date, order: .reverse) private var sessions: [BrushingSession]
    @State private var vm = CalendarViewModel()
    @State private var appear = false

    private let weekdays = ["Пн","Вт","Ср","Чт","Пт","Сб","Вс"]
    private let cols = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)

    var body: some View {
        ZStack {
            BreathingBackgroundView()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    header
                    stats
                    calendar

                    if sessions.isEmpty {
                        emptyState
                    } else {
                        history
                    }

                    Spacer().frame(height: 80)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
            }
        }
        .onAppear {
            vm.calculateStats(sessions: sessions)
            withAnimation(.spring(response: 0.5)) { appear = true }
        }
        .onChange(of: sessions.count) { _, _ in vm.calculateStats(sessions: sessions) }
    }

    // MARK: - Header
    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Прогресс")
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.bText1, Color.bMint.opacity(0.7)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                if vm.currentStreak > 0 {
                    HStack(spacing: 6) {
                        // Animated fire glow
                        ZStack {
                            Circle()
                                .fill(Color.orange.opacity(0.2))
                                .frame(width: 26, height: 26)
                                .blur(radius: 4)
                            Text("*")
                                .font(.system(size: 20))
                                .foregroundStyle(.orange)
                        }
                        Text("Серия: \(vm.currentStreak) дн.")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundStyle(.orange)
                            .shadow(color: .orange.opacity(0.3), radius: 4)
                    }
                } else {
                    Text("Начните первую чистку")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(Color.bText2)
                }
            }
            Spacer()
        }
        .padding(.top, 48)
        .opacity(appear ? 1 : 0)
        .offset(y: appear ? 0 : 20)
    }

    // MARK: - Stats
    private var stats: some View {
        HStack(spacing: 10) {
            miniStat(v: "\(vm.currentStreak)", l: "СЕРИЯ", c: .orange, icon: "flame.fill")
            miniStat(v: "\(vm.bestStreak)", l: "РЕКОРД", c: .bWarn, icon: "trophy.fill")
            miniStat(v: "\(Int(vm.averageScore))%", l: "СРЕДН.", c: .bMint, icon: "chart.line.uptrend.xyaxis")
        }
        .opacity(appear ? 1 : 0)
        .offset(y: appear ? 0 : 15)
    }

    private func miniStat(v: String, l: String, c: Color, icon: String) -> some View {
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .fill(c.opacity(0.12))
                    .frame(width: 28, height: 28)
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(c)
            }
            Text(v)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(Color.bText1)
            Text(l)
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .tracking(1)
                .foregroundStyle(Color.bText3)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.bCard)
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(Color.white.opacity(0.05), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.2), radius: 15, y: 5)
        )
    }

    // MARK: - Calendar
    private var calendar: some View {
        VStack(spacing: 14) {
            HStack {
                Button { Haptic.tick(); vm.prevMonth() } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.bText2)
                        .frame(width: 36, height: 36)
                        .background(Circle().fill(Color.bSurface))
                }
                Spacer()
                Text(vm.monthTitle())
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.bText1)
                Spacer()
                Button { Haptic.tick(); vm.nextMonth() } label: {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.bText2)
                        .frame(width: 36, height: 36)
                        .background(Circle().fill(Color.bSurface))
                }
            }

            LazyVGrid(columns: cols, spacing: 4) {
                ForEach(weekdays, id: \.self) { d in
                    Text(d)
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.bText3)
                }
            }

            let days = vm.daysInMonth()
            let off = vm.firstWeekday()
            LazyVGrid(columns: cols, spacing: 5) {
                ForEach(0..<off, id: \.self) { _ in Color.clear.frame(height: 40) }
                ForEach(days, id: \.self) { d in dayCell(d) }
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(Color.bCard)
                .overlay(
                    RoundedRectangle(cornerRadius: 26, style: .continuous)
                        .stroke(Color.white.opacity(0.05), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.2), radius: 20, y: 8)
        )
    }

    private func dayCell(_ date: Date) -> some View {
        let cal = Calendar.current
        let num = cal.component(.day, from: date)
        let today = cal.isDateInToday(date)
        let sc = vm.bestScore(on: date, in: sessions)
        let has = sc != nil
        let score = sc ?? 0

        return ZStack {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(has ? scoreColor(score).opacity(0.12) : Color.clear)
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(today ? Color.bMint.opacity(0.5) : (has ? scoreColor(score).opacity(0.3) : .clear), lineWidth: today ? 1.5 : 1)
                )

            Text("\(num)")
                .font(.system(size: 13, weight: has || today ? .bold : .regular, design: .rounded))
                .foregroundStyle(has ? scoreColor(score) : (today ? Color.bText1 : Color.bText3))
        }
        .frame(height: 40)
    }

    private func scoreColor(_ score: Double) -> Color {
        switch score {
        case 80...100: return .bSuccess
        case 60..<80: return .bMint
        default: return .bWarn
        }
    }

    // MARK: - Empty State
    private var emptyState: some View {
        VStack(spacing: 18) {
            ZStack {
                Circle()
                    .fill(Color.bMint.opacity(0.08))
                    .frame(width: 100, height: 100)
                Image(systemName: "calendar.badge.plus")
                    .font(.system(size: 40))
                    .foregroundStyle(Color.bMint.opacity(0.4))
            }

            Text("Пока нет сессий")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(Color.bText2)
            Text("Начните первую чистку,\nчтобы увидеть прогресс")
                .font(.system(size: 13, design: .rounded))
                .foregroundStyle(Color.bText3)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 28)
    }

    // MARK: - History
    private var history: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("ИСТОРИЯ")
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .tracking(1)
                .foregroundStyle(Color.bText3)
                .padding(.leading, 4)

            ForEach(sessions.prefix(5)) { s in
                HStack(spacing: 14) {
                    // Score badge with gradient
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [scoreColor(s.correctPercentage).opacity(0.2), scoreColor(s.correctPercentage).opacity(0.05)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 44, height: 44)
                        Text(s.scoreGrade)
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundStyle(scoreColor(s.correctPercentage))
                    }

                    VStack(alignment: .leading, spacing: 3) {
                        Text("\(Int(s.correctPercentage))%")
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.bText1)
                        Text(s.date.formatted(date: .abbreviated, time: .shortened))
                            .font(.system(size: 12, design: .rounded))
                            .foregroundStyle(Color.bText3)
                    }
                    Spacer()
                    Text(s.formattedDuration)
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .monospacedDigit()
                        .foregroundStyle(Color.bText2)
                }
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(Color.bCard)
                        .overlay(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .stroke(Color.white.opacity(0.04), lineWidth: 1)
                        )
                        .shadow(color: Color.black.opacity(0.15), radius: 12, y: 4)
                )
            }
        }
    }
}
