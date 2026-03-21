import Vision
import CoreMedia
import SwiftUI

// MARK: - Motion Status

enum MotionStatus: Equatable {
    case idle
    case analyzing
    case correct
    case incorrect
    case noHand
    case handTooFar  // NEW: Hand is detected, but not near the face

    var color: Color {
        switch self {
        case .correct:   return .bSuccess
        case .incorrect: return .bError
        case .analyzing: return .bWarn
        case .noHand, .idle, .handTooFar: return .gray.opacity(0.5)
        }
    }

    var icon: String {
        switch self {
        case .correct:   return "checkmark.circle.fill"
        case .incorrect: return "xmark.circle.fill"
        case .analyzing: return "ellipsis.circle.fill"
        case .noHand:    return "hand.raised.slash.fill"
        case .handTooFar: return "person.crop.circle.badge.exclamationmark.fill"
        case .idle:      return "circle.dashed"
        }
    }

    var label: String {
        switch self {
        case .correct:   return "Отлично! Правильное движение"
        case .incorrect: return "Двигайте правильно"
        case .analyzing: return "Анализирую движения…"
        case .noHand:    return "Покажите руку камере"
        case .handTooFar: return "Поднесите щетку ко рту"
        case .idle:      return "Нажмите «Начать»"
        }
    }
}

// MARK: - Tracker

@Observable
final class HandMotionTracker {

    var status: MotionStatus = .idle
    var confidence: Double = 0.0
    var verticalRatio: Double = 0.0

    // --- Tuning knobs (much less jittery) ---
    private var positions: [CGPoint] = []
    private let windowSize = 40           // larger window → smoother
    private let minSamples = 18           // need more data before judging
    private let verticalThreshold: CGFloat = 0.48
    private let minMovement: CGFloat = 0.015  // ignore micro-jitter
    
    // Smoothing: keep a rolling average of the last N verdicts
    private var verdictHistory: [Bool] = []  // true = correct
    private let verdictSmoothing = 6         // need 6 similar verdicts to flip
    
    // Grace period: don't judge for the first N seconds
    private var frameCount = 0
    private let warmupFrames = 30            // ~1 second at 30fps
    
    // Debounce: prevent rapid flipping
    private var lastStatusChangeTime: Date = .distantPast
    private let debounceInterval: TimeInterval = 0.8

    // Hand-to-Face Spatial Constraints
    private let maxFaceDistanceThreshold: CGFloat = 0.5 // Relative screen distance
    private var lastFaceWidth: CGFloat = 0.0          // Used to limit stroke amplitude

    // MARK: - Process Frame

    func processFrame(_ buffer: CMSampleBuffer, zone: BrushingZone? = nil) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(buffer) else { return }

        let handRequest = VNDetectHumanHandPoseRequest()
        handRequest.maximumHandCount = 1
        
        let faceRequest = VNDetectFaceRectanglesRequest() // Find the user's face

        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up)

        do {
            try handler.perform([handRequest, faceRequest])

            // 1. Check for missing Hand
            guard let handObs = handRequest.results?.first else {
                updateStatus(.noHand)
                return
            }

            // 2. Identify index finger knuckle (more accurate for brush head than wrist)
            let indexKnuckle = try handObs.recognizedPoint(.indexMCP)
            guard indexKnuckle.confidence > 0.3 else {
                updateStatus(.noHand)
                return
            }
            let handPoint = CGPoint(x: indexKnuckle.location.x, y: indexKnuckle.location.y)

            // 3. Optional: Check for Face (if no face is found, we fall back to normal tracking)
            if let faceObs = faceRequest.results?.first {
                let faceRect = faceObs.boundingBox
                // Calculate distance from wrist to the center of the face bounding box
                let faceCenter = CGPoint(x: faceRect.midX, y: faceRect.midY)
                self.lastFaceWidth = faceRect.width
                
                let distance = hypot(handPoint.x - faceCenter.x, handPoint.y - faceCenter.y)
                
                // If the hand is too far from the detected face, do not count it as brushing
                if distance > maxFaceDistanceThreshold {
                    updateStatus(.handTooFar)
                    positions.removeAll(keepingCapacity: true) // Clear history if hand moved away
                    return
                }
            }

            // 4. Continue with Kinematic Recording
            frameCount += 1
            positions.append(handPoint)
            if positions.count > windowSize {
                positions.removeFirst(positions.count - windowSize)
            }

            // Don't analyze during warmup
            if frameCount < warmupFrames {
                updateStatus(.analyzing)
                return
            }

            analyzeMotion(zone: zone)

        } catch {
            // Vision request failed — skip frame
        }
    }

    // MARK: - Motion Analysis (Kinematic)

    private func analyzeMotion(zone: BrushingZone?) {
        guard positions.count >= minSamples else {
            updateStatus(.analyzing)
            return
        }

        // 1. Calculate Velocities (dx, dy) and Energy (Amplitude/Variance)
        var velocitiesX: [CGFloat] = []
        var velocitiesY: [CGFloat] = []
        
        var sumX: CGFloat = 0
        var sumY: CGFloat = 0

        for i in 1..<positions.count {
            let dx = positions[i].x - positions[i - 1].x
            let dy = positions[i].y - positions[i - 1].y
            velocitiesX.append(dx)
            velocitiesY.append(dy)
            sumX += positions[i].x
            sumY += positions[i].y
        }
        
        // Calculate Variance (Energy/Amplitude of movement)
        let meanX = sumX / CGFloat(positions.count - 1)
        let meanY = sumY / CGFloat(positions.count - 1)
        
        var varianceX: CGFloat = 0
        var varianceY: CGFloat = 0
        for i in 1..<positions.count {
            varianceX += pow(positions[i].x - meanX, 2)
            varianceY += pow(positions[i].y - meanY, 2)
        }
        varianceX /= CGFloat(positions.count - 1)
        varianceY /= CGFloat(positions.count - 1)
        
        let totalEnergy = varianceX + varianceY
        
        // If the energy is too low, it's just micro-jitter or holding still
        let minEnergyThreshold: CGFloat = 0.0001
        guard totalEnergy > minEnergyThreshold else {
            updateStatus(.analyzing)
            return
        }

        // 2. Calculate Zero-Crossings (to find frequency/strokes)
        // A stroke happens when velocity changes sign (e.g. up then down, left then right)
        var zeroCrossingsX = 0
        var zeroCrossingsY = 0
        
        for i in 1..<velocitiesX.count {
            if (velocitiesX[i] >= 0 && velocitiesX[i-1] < 0) || (velocitiesX[i] < 0 && velocitiesX[i-1] >= 0) {
                zeroCrossingsX += 1
            }
            if (velocitiesY[i] >= 0 && velocitiesY[i-1] < 0) || (velocitiesY[i] < 0 && velocitiesY[i-1] >= 0) {
                zeroCrossingsY += 1
            }
        }
        
        // Max crossings between X and Y axes gives us the dominant brushing direction
        let maxCrossings = max(zeroCrossingsX, zeroCrossingsY)
        
        // 3. Calculate Frequency (Hz)
        // 1 full stroke = 2 zero crossings (back and forth)
        let strokes = Double(maxCrossings) / 2.0
        
        // Time window in seconds (assuming roughly 30 fps for standard camera CMSampleBuffer)
        let fps: Double = 30.0
        let timeWindowSeconds = Double(positions.count) / fps
        let currentHz = strokes / timeWindowSeconds
        
        // Realistic human brushing frequency is typically between 2.5 Hz and 8.0 Hz.
        // TIGHTENED (Phase 6): Force strict 3.0 to 7.5 Hz for hyper-precision
        let isCorrectHz = currentHz >= 3.0 && currentHz <= 7.5
        
        // --- PHASE 7: Face-Relative Stroke Amplitude Limits ---
        // Calculate the physical bounding box (span) of the recent movements
        var minX: CGFloat = 1.0, maxX: CGFloat = 0.0
        var minY: CGFloat = 1.0, maxY: CGFloat = 0.0
        for p in positions {
            minX = min(minX, p.x)
            maxX = max(maxX, p.x)
            minY = min(minY, p.y)
            maxY = max(maxY, p.y)
        }
        let spanX = maxX - minX
        let spanY = maxY - minY
        
        // The stroke should be localized micro-movements (approx 35% of face width max)
        // If the max span is larger, they are waving their entire arm.
        var isGrossWaving = false
        if lastFaceWidth > 0 {
            let maxAllowedSpan = lastFaceWidth * 0.35 // 35% of face width
            if spanX > maxAllowedSpan || spanY > maxAllowedSpan {
                isGrossWaving = true
            }
        }
        
        // --- PHASE 5 & 6: Zone-Specific Hyper-Precise Directional Logic ---
        var isCorrectDirection = true
        if isCorrectHz && !isGrossWaving, let zone = zone {
            let totalVar = varianceX + varianceY
            if totalVar > 0 {
                let ratioX = varianceX / totalVar
                let ratioY = varianceY / totalVar
                
                if zone.surface == .chewing {
                    // Chewing requires STRICT horizontal scrubbing (>75% X variance)
                    if ratioX < 0.75 {
                        isCorrectDirection = false
                    }
                } else {
                    // Outer/Inner requires STRICT vertical sweeping (>65% Y variance)
                    // (This allows 35% horizontal variance to accommodate the circular twisting arc of the wrist)
                    if ratioY < 0.65 {
                        isCorrectDirection = false
                    }
                }
            }
        }
        
        // 4. Update Verdict History & Smooth
        let finalVerdict = isCorrectHz && isCorrectDirection && !isGrossWaving
        verdictHistory.append(finalVerdict)
        if verdictHistory.count > verdictSmoothing * 2 {
            verdictHistory.removeFirst()
        }
        
        let recentVerdicts = verdictHistory.suffix(verdictSmoothing)
        guard recentVerdicts.count >= verdictSmoothing else {
            updateStatus(.analyzing)
            return
        }
        
        let allCorrect = recentVerdicts.allSatisfy { $0 }
        let allIncorrect = recentVerdicts.allSatisfy { !$0 }
        
        // Debounce: don't flip too fast
        let now = Date()
        guard now.timeIntervalSince(lastStatusChangeTime) > debounceInterval else { return }
        
        // Confidence/Intensity based on Hz and Energy
        let targetHz = 4.0
        let hzScore = 1.0 - min(1.0, abs(currentHz - targetHz) / 4.0) // 1.0 when perfectly 4 Hz
        let energyScore = min(1.0, Double(totalEnergy) * 2000)
        let conf = (hzScore * 0.7) + (energyScore * 0.3)
        
        DispatchQueue.main.async {
            self.verticalRatio = currentHz // Store Hz here temporarily to avoid breaking ViewModels
            self.confidence = max(0.1, conf)
            
            if allCorrect && self.status != .correct {
                self.status = .correct
                self.lastStatusChangeTime = now
            } else if allIncorrect && self.status != .incorrect {
                self.status = .incorrect
                self.lastStatusChangeTime = now
            }
        }
    }

    // MARK: - Helpers

    private func updateStatus(_ newStatus: MotionStatus) {
        DispatchQueue.main.async {
            // Don't downgrade from correct/incorrect to analyzing too eagerly
            if (newStatus == .analyzing || newStatus == .noHand) &&
               (self.status == .correct || self.status == .incorrect) &&
               Date().timeIntervalSince(self.lastStatusChangeTime) < 1.5 {
                return // Hold current status briefly
            }
            
            self.status = newStatus
            if newStatus == .noHand || newStatus == .handTooFar { self.confidence = 0 }
        }
    }

    func reset() {
        positions.removeAll()
        verdictHistory.removeAll()
        frameCount = 0
        status = .idle
        confidence = 0
        verticalRatio = 0
        lastStatusChangeTime = .distantPast
    }
}
