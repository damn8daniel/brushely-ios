import Foundation
import SwiftData

@Model
final class BrushingSession {
    @Attribute(.unique) var id: UUID
    var date: Date
    var duration: TimeInterval
    var correctPercentage: Double
    var totalMovements: Int
    var correctMovements: Int

    init(
        date: Date = .now,
        duration: TimeInterval = 0,
        correctPercentage: Double = 0,
        totalMovements: Int = 0,
        correctMovements: Int = 0
    ) {
        self.id = UUID()
        self.date = date
        self.duration = duration
        self.correctPercentage = correctPercentage
        self.totalMovements = totalMovements
        self.correctMovements = correctMovements
    }

    var scoreGrade: String {
        switch correctPercentage {
        case 90...100: return "A+"
        case 80..<90: return "A"
        case 70..<80: return "B"
        case 60..<70: return "C"
        default: return "D"
        }
    }

    var formattedDuration: String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
