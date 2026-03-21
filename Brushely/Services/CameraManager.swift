import AVFoundation
import Combine

final class CameraManager: NSObject, ObservableObject {

    let session = AVCaptureSession()

    @Published var isAuthorized = false
    @Published var errorMessage: String?

    var onFrameCaptured: ((CMSampleBuffer) -> Void)?

    private let videoOutput = AVCaptureVideoDataOutput()
    private let queue = DispatchQueue(label: "com.brushely.camera", qos: .userInitiated)

    override init() {
        super.init()
    }

    // MARK: - Authorization

    func requestAccess() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            DispatchQueue.main.async { self.isAuthorized = true }
            configureSession()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    self?.isAuthorized = granted
                    if granted { self?.configureSession() }
                }
            }
        case .denied, .restricted:
            DispatchQueue.main.async {
                self.isAuthorized = false
                self.errorMessage = "Доступ к камере отклонён. Включите в Настройках."
            }
        @unknown default:
            break
        }
    }

    // MARK: - Session Configuration

    private func configureSession() {
        queue.async { [weak self] in
            guard let self else { return }
            session.beginConfiguration()
            session.sessionPreset = .high

            guard let camera = AVCaptureDevice.default(
                .builtInWideAngleCamera, for: .video, position: .front
            ) else {
                DispatchQueue.main.async { self.errorMessage = "Фронтальная камера недоступна" }
                return
            }

            do {
                let input = try AVCaptureDeviceInput(device: camera)
                guard session.canAddInput(input) else { return }
                session.addInput(input)
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Ошибка камеры: \(error.localizedDescription)"
                }
                return
            }

            videoOutput.setSampleBufferDelegate(self, queue: queue)
            videoOutput.alwaysDiscardsLateVideoFrames = true
            guard session.canAddOutput(videoOutput) else { return }
            session.addOutput(videoOutput)

            if let connection = videoOutput.connection(with: .video) {
                connection.isVideoMirrored = true
                if connection.isVideoRotationAngleSupported(90) {
                    connection.videoRotationAngle = 90
                }
            }

            session.commitConfiguration()
        }
    }

    // MARK: - Capture Control

    func startCapture() {
        queue.async { [weak self] in
            guard let self, !self.session.isRunning else { return }
            self.session.startRunning()
        }
    }

    func stopCapture() {
        queue.async { [weak self] in
            guard let self, self.session.isRunning else { return }
            self.session.stopRunning()
        }
    }
}

// MARK: - Sample Buffer Delegate

extension CameraManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        onFrameCaptured?(sampleBuffer)
    }
}
