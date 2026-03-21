import SwiftUI
import SwiftData

@Observable
final class CalendarViewModel {

    var selectedDate = Date()
    var currentMonth = Date()
    var currentStreak = 0
    var bestStreak = 0
    var totalSessions = 0
    var averageScore: Double = 0

    // MARK: - Stats

    func calculateStats(sessions: [BrushingSession]) {
        totalSessions = sessions.count
        guard !sessions.isEmpty else {
            currentStreak = 0; bestStreak = 0; averageScore = 0
            return
        }
        averageScore = sessions.map(\.correctPercentage).reduce(0, +) / Double(sessions.count)
        calculateStreaks(sessions: sessions)
    }

    private func calculateStreaks(sessions: [BrushingSession]) {
        let cal = Calendar.current
        let uniqueDays = Set(sessions.map { cal.startOfDay(for: $0.date) }).sorted(by: >)

        var streak = 0, maxStreak = 0
        var expected = cal.startOfDay(for: Date())

        for date in uniqueDays {
            if date == expected {
                streak += 1
                maxStreak = max(maxStreak, streak)
                expected = cal.date(byAdding: .day, value: -1, to: expected)!
            } else if date < expected && streak == 0 {
                expected = cal.date(byAdding: .day, value: -1, to: expected)!
                if date == expected {
                    streak += 1
                    maxStreak = max(maxStreak, streak)
                    expected = cal.date(byAdding: .day, value: -1, to: expected)!
                } else { break }
            } else { break }
        }
        currentStreak = streak
        bestStreak = maxStreak
    }

    // MARK: - Helpers

    func sessionsFor(_ date: Date, in all: [BrushingSession]) -> [BrushingSession] {
        let cal = Calendar.current
        return all.filter { cal.isDate($0.date, inSameDayAs: date) }
    }

    func hasSession(on date: Date, in all: [BrushingSession]) -> Bool {
        !sessionsFor(date, in: all).isEmpty
    }

    func bestScore(on date: Date, in all: [BrushingSession]) -> Double? {
        sessionsFor(date, in: all).map(\.correctPercentage).max()
    }

    // MARK: - Month helpers

    func daysInMonth() -> [Date] {
        let cal = Calendar.current
        guard let range = cal.range(of: .day, in: .month, for: currentMonth),
              let firstDay = cal.date(from: cal.dateComponents([.year, .month], from: currentMonth))
        else { return [] }
        return range.compactMap { cal.date(byAdding: .day, value: $0 - 1, to: firstDay) }
    }

    func firstWeekday() -> Int {
        let cal = Calendar.current
        guard let first = cal.date(from: cal.dateComponents([.year, .month], from: currentMonth)) else { return 0 }
        return (cal.component(.weekday, from: first) + 5) % 7  // Monday = 0
    }

    func monthTitle() -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ru_RU")
        f.dateFormat = "LLLL yyyy"
        return f.string(from: currentMonth).capitalized
    }

    func prevMonth() {
        currentMonth = Calendar.current.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
    }

    func nextMonth() {
        currentMonth = Calendar.current.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
    }
}
