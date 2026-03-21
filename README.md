# Brushely - iOS Dental Health App

A modern SwiftUI application designed to help users build and maintain healthy dental hygiene habits. Brushely guides you through each brushing session with real-time feedback, interactive visuals, and motion tracking.

## Features

- **Brushing Timer** — Guided 2-minute timer with a ring indicator and zone-by-zone progression
- **Interactive Tooth Map** — Visual map of all dental zones showing brushing coverage and progress
- **Camera Preview** — Live camera feed integration for brushing posture awareness
- **Hand Motion Tracking** — CoreMotion-based detection of brushing movements with real-time guidance
- **Particle Effects** — Animated sparkle effects that reward completed zones
- **Brushing Calendar** — Track your brushing history and streaks over time
- **Animated Tooth** — Breathing background and animated tooth visuals for an engaging experience

## Architecture

The project follows the **MVVM (Model-View-ViewModel)** pattern:

```
Brushely/
├── App/                # App entry point
├── Models/             # Data models (BrushingSession, BrushingZone)
├── ViewModels/         # Business logic (BrushingViewModel, CalendarViewModel)
├── Views/              # SwiftUI views
├── Services/           # Camera and motion tracking services
└── Extensions/         # Color and utility extensions
```

## Tech Stack

| Technology | Purpose |
|---|---|
| **Swift** | Primary language |
| **SwiftUI** | Declarative UI framework |
| **AVFoundation** | Camera preview and media handling |
| **CoreMotion** | Accelerometer and gyroscope for hand motion tracking |

## Requirements

- iOS 17.0+
- Xcode 15.0+

## Screenshots

> _Screenshots coming soon._

## Getting Started

1. Clone the repository:
   ```bash
   git clone https://github.com/damn888daniel/brushely-ios.git
   ```
2. Open `Brushely.xcodeproj` in Xcode.
3. Select a target device or simulator.
4. Build and run.

## License

This project is available for personal and educational use.
