import SwiftUI
import SwiftData

struct BrushingView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = BrushingViewModel()
    @StateObject private var camera = CameraManager()
    @State private var tracker = HandMotionTracker()

    var body: some View {
        ZStack {
            // Living breathing background
            BreathingBackgroundView()

            if viewModel.isActive {
                activeView
            } else {
                idleView
            }
        }
        .fullScreenCover(isPresented: $viewModel.showCompletion) {
            CompletionView(
                percentage: viewModel.correctPercentage,
                duration: viewModel.elapsedTime,
                correctMovements: viewModel.correctMovements,
                totalMovements: viewModel.totalMovements,
                onSave: { viewModel.saveSession(context: modelContext); viewModel.showCompletion = false; tracker.reset() },
                onDismiss: { viewModel.showCompletion = false; tracker.reset() }
            )
        }
        .onAppear { camera.requestAccess() }
        .onChange(of: tracker.status) { _, s in viewModel.updateStatus(s) }
        .animation(.spring(response: 0.45, dampingFraction: 0.85), value: viewModel.isActive)
    }

    // MARK: - Idle — Living Hero Screen

    private var idleView: some View {
        VStack(spacing: 0) {
            Spacer()

            // Animated hero — pulsing tooth with floating orbs
            ZStack {
                // Ambient orbs
                FloatingOrb(color: .bMint, size: 160, delay: 0)
                    .offset(x: -30, y: -20)
                FloatingOrb(color: .bViolet, size: 120, delay: 1.5)
                    .offset(x: 40, y: 30)

                // Pulse rings
                PulseRing(color: Color.bMint.opacity(0.2), lineWidth: 1.5)
                    .frame(width: 200, height: 200)
                PulseRing(color: Color.bMint.opacity(0.1), lineWidth: 1)
                    .frame(width: 240, height: 240)

                // Timer ring
                ZStack {
                    // Track
                    Circle()
                        .stroke(Color.bMint.opacity(0.08), lineWidth: 6)
                        .frame(width: 190, height: 190)

                    // Fill
                    Circle()
                        .trim(from: 0, to: 0.83)
                        .stroke(
                            AngularGradient(
                                colors: [Color.bMint, Color.bMint.opacity(0.6), Color(red: 0, green: 0.6, blue: 0.9), Color.bMint],
                                center: .center
                            ),
                            style: StrokeStyle(lineWidth: 6, lineCap: .round)
                        )
                        .frame(width: 190, height: 190)
                        .rotationEffect(.degrees(-90))
                        .shadow(color: Color.bMint.opacity(0.4), radius: 12)

                    VStack(spacing: 4) {
                        Text("2:00")
                            .font(.system(size: 44, weight: .bold, design: .rounded))
                            .monospacedDigit()
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color.bText1, Color.bMint.opacity(0.8)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                        Text("8 зон")
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundStyle(Color.bText2)
                    }
                }
            }

            Spacer().frame(height: 36)

            // Animated zone strip
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(BrushingZone.standardSequence) { z in
                        VStack(spacing: 6) {
                            ZoneThumbnailAnimated(zone: z, isCurrent: z.id == 0, size: 44)

                            Text("\(z.id + 1)")
                                .font(.system(size: 10, weight: .bold, design: .rounded))
                                .foregroundStyle(z.id == 0 ? Color.bMint : Color.bText3)
                        }
                        .frame(width: 56)
                    }
                }
                .padding(.horizontal, 20)
            }

            Spacer()

            // Hint card
            HStack(spacing: 14) {
                // Animated mini tooth
                ZStack {
                    Circle()
                        .fill(Color.bMint.opacity(0.1))
                        .frame(width: 44, height: 44)
                    Image(systemName: "mouth.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(Color.bMint)
                }

                Text("Чистите зубы перед камерой —\nмы отследим технику")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(Color.bText2)
                    .lineLimit(2)
                Spacer()
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color.bCard)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(Color.white.opacity(0.05), lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.2), radius: 20, y: 8)
            )
            .padding(.horizontal, 24)

            Spacer().frame(height: 16)

            // Start button with glow
            Button {
                Haptic.heavy(); startSession()
            } label: {
                Text("НАЧАТЬ")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .tracking(2)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [Color.bMint, Color(red: 0.00, green: 0.65, blue: 0.80)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    )
                    .overlay(
                        Capsule()
                            .stroke(Color.white.opacity(0.15), lineWidth: 1)
                    )
                    .shadow(color: Color.bMint.opacity(0.4), radius: 24, y: 10)
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 40)
            .padding(.bottom, 100)
        }
    }

    // MARK: - Active — Camera + HUD

    private var activeView: some View {
        ZStack {
            GeometryReader { g in
                if camera.isAuthorized {
                    CameraPreviewView(session: camera.session)
                        .frame(width: g.size.width, height: g.size.height)
                        .ignoresSafeArea()
                } else {
                    Color.bBackground.ignoresSafeArea()
                        .overlay {
                            VStack(spacing: 14) {
                                ZStack {
                                    Circle()
                                        .fill(Color.bCard)
                                        .frame(width: 100, height: 100)
                                    Image(systemName: "camera.fill")
                                        .font(.system(size: 36))
                                        .foregroundStyle(Color.bText3)
                                }
                                Text("Нет доступа к камере")
                                    .font(.system(size: 14, weight: .medium, design: .rounded))
                                    .foregroundStyle(Color.bText2)
                            }
                        }
                }
            }

            // Gradient overlays
            VStack {
                LinearGradient(
                    colors: [Color.black.opacity(0.65), .clear],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 130)
                .ignoresSafeArea(edges: .top)
                Spacer()
            }

            VStack {
                Spacer()
                LinearGradient(
                    colors: [.clear, Color.black.opacity(0.80)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 300)
            }

            StatusOverlayView(
                status: viewModel.currentStatus,
                intensity: tracker.confidence,
                hz: tracker.verticalRatio
            ).offset(y: -50)

            VStack(spacing: 0) {
                HStack {
                    // Score pill with gradient
                    HStack(spacing: 6) {
                        Circle()
                            .fill(viewModel.currentStatus == .correct ? Color.bSuccess : Color.bText3)
                            .frame(width: 8, height: 8)
                            .shadow(color: viewModel.currentStatus == .correct ? Color.bSuccess.opacity(0.5) : .clear, radius: 4)
                        Text("\(Int(viewModel.correctPercentage))%")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .monospacedDigit().foregroundStyle(.white)
                            .contentTransition(.numericText())
                    }
                    .padding(.horizontal, 14).padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(.ultraThinMaterial)
                            .overlay(Capsule().stroke(Color.white.opacity(0.1), lineWidth: 1))
                    )

                    Spacer()
                    TimerRingView(progress: viewModel.progress, timeString: viewModel.timeString)
                }
                .padding(.horizontal, 20).padding(.top, 8)

                Spacer()

                VStack(spacing: 10) {
                    ZoneGuideView(zone: viewModel.currentZone, zoneProgress: viewModel.zoneProgress, stepLabel: viewModel.zoneStepLabel)

                    Button { Haptic.medium(); stopSession() } label: {
                        Text("СТОП")
                            .font(.system(size: 14, weight: .bold, design: .rounded)).tracking(1)
                            .foregroundStyle(Color.bError)
                            .frame(maxWidth: .infinity).padding(.vertical, 14)
                            .background(
                                Capsule()
                                    .fill(Color.bError.opacity(0.1))
                                    .overlay(Capsule().stroke(Color.bError.opacity(0.3), lineWidth: 1))
                            )
                    }
                }
                .padding(.horizontal, 16).padding(.bottom, 20)
            }
        }
    }

    private func startSession() {
        camera.onFrameCaptured = { [tracker, viewModel] buf in tracker.processFrame(buf, zone: viewModel.currentZone) }
        camera.startCapture(); viewModel.start()
    }
    private func stopSession() { camera.stopCapture(); viewModel.complete() }
}
