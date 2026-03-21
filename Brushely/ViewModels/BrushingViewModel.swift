import SwiftUI
import SwiftData

@Observable
final class BrushingViewModel {

    // Session State
    var isActive = false
    var elapsedTime: TimeInterval = 0
    var correctMovements = 0
    var totalMovements = 0
    var currentStatus: MotionStatus = .idle
    var showCompletion = false

    // Zone Tracking
    let zones = BrushingZone.standardSequence
    var currentZoneIndex = 0
    var zoneElapsed: TimeInterval = 0

    var currentZone: BrushingZone { zones[currentZoneIndex] }
    var totalDuration: TimeInterval { zones.reduce(0) { $0 + $1.duration } }
    var progress: Double { min(1.0, elapsedTime / totalDuration) }
    var zoneProgress: Double { min(1.0, zoneElapsed / currentZone.duration) }
    var zoneStepLabel: String { "\(currentZoneIndex + 1) / \(zones.count)" }

    var correctPercentage: Double {
        guard totalMovements > 0 else { return 0 }
        return Double(correctMovements) / Double(totalMovements) * 100
    }

    var timeString: String {
        let remaining = max(0, totalDuration - elapsedTime)
        let m = Int(remaining) / 60
        let s = Int(remaining) % 60
        return String(format: "%d:%02d", m, s)
    }

    private var timer: Timer?
    private var sampleTimer: Timer?

    // MARK: - Session Control

    func start() {
        isActive = true
        elapsedTime = 0
        zoneElapsed = 0
        currentZoneIndex = 0
        correctMovements = 0
        totalMovements = 0
        currentStatus = .analyzing

        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self else { return }
            self.elapsedTime += 0.1
            self.zoneElapsed += 0.1

            // Auto-advance to next zone
            if self.zoneElapsed >= self.currentZone.duration {
                self.advanceZone()
            }

            // Session complete
            if self.elapsedTime >= self.totalDuration {
                self.complete()
            }
        }

        sampleTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            guard let self else { return }
            guard self.currentStatus == .correct || self.currentStatus == .incorrect else { return }
            self.totalMovements += 1
            if self.currentStatus == .correct { self.correctMovements += 1 }
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        sampleTimer?.invalidate()
        sampleTimer = nil
        isActive = false
    }

    func complete() {
        stop()
        showCompletion = true
    }

    func updateStatus(_ status: MotionStatus) {
        currentStatus = status
    }

    // MARK: - Zone Navigation

    private func advanceZone() {
        if currentZoneIndex < zones.count - 1 {
            currentZoneIndex += 1
            zoneElapsed = 0
            Haptic.success()
        }
    }

    // MARK: - Persistence

    func saveSession(context: ModelContext) {
        let session = BrushingSession(
            date: .now,
            duration: elapsedTime,
            correctPercentage: correctPercentage,
            totalMovements: totalMovements,
            correctMovements: correctMovements
        )
        context.insert(session)
    }
}
