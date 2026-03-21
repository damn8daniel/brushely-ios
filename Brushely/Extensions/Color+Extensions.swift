import SwiftUI
import UIKit

// MARK: - Brushely Design System — Warm Premium Light Theme

extension Color {
    // Primary — warm sage/teal
    static let bMint     = Color(red: 0.18, green: 0.72, blue: 0.63)   // #2DB8A0
    static let bMintDark = Color(red: 0.14, green: 0.59, blue: 0.52)   // #239685
    static let bMintLight = Color(red: 0.37, green: 0.86, blue: 0.77)  // #5EDBC4
    static let bMintPale = Color(red: 0.91, green: 0.97, blue: 0.96)   // #E8F8F4

    // Warm accents
    static let bCoral    = Color(red: 1.00, green: 0.49, blue: 0.42)   // #FF7E6B
    static let bCoralL   = Color(red: 1.00, green: 0.89, blue: 0.87)   // #FFE4DF
    static let bAmber    = Color(red: 0.96, green: 0.65, blue: 0.14)   // #F5A623
    static let bAmberL   = Color(red: 1.00, green: 0.96, blue: 0.88)   // #FFF4E0
    static let bViolet   = Color(red: 0.91, green: 0.38, blue: 0.49)   // #E8627C
    static let bRose     = Color(red: 0.99, green: 0.91, blue: 0.93)   // #FDE8EC

    // Backgrounds — warm whites
    static let bBackground = Color(red: 0.98, green: 0.97, blue: 0.96) // #FAF8F5
    static let bSurface    = Color(red: 0.95, green: 0.94, blue: 0.92) // #F3F0EB
    static let bCard       = Color.white                                // #FFFFFF
    static let bCardLight  = Color(red: 1.00, green: 0.98, blue: 0.96) // #FFF9F4

    // Semantic
    static let bSuccess = Color(red: 0.20, green: 0.78, blue: 0.48)    // #34C77B
    static let bError   = Color(red: 0.95, green: 0.36, blue: 0.36)    // #F25C5C
    static let bWarn    = Color(red: 0.96, green: 0.65, blue: 0.14)    // #F5A623

    // Text — warm charcoals
    static let bText1 = Color(red: 0.12, green: 0.16, blue: 0.21)     // #1E2A36
    static let bText2 = Color(red: 0.42, green: 0.48, blue: 0.55)     // #6B7A8D
    static let bText3 = Color(red: 0.64, green: 0.69, blue: 0.75)     // #A3B1BF
}

// MARK: - Gradient Presets

extension LinearGradient {
    static let bMintGradient = LinearGradient(
        colors: [Color.bMint, Color.bMintLight],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let bPrimaryGradient = LinearGradient(
        colors: [Color.bMint, Color.bMintLight],
        startPoint: .leading,
        endPoint: .trailing
    )

    static let bSuccessGradient = LinearGradient(
        colors: [Color.bSuccess, Color.bMint],
        startPoint: .leading,
        endPoint: .trailing
    )
}

// MARK: - Haptics

struct Haptic {
    static func light()   { UIImpactFeedbackGenerator(style: .light).impactOccurred() }
    static func medium()  { UIImpactFeedbackGenerator(style: .medium).impactOccurred() }
    static func heavy()   { UIImpactFeedbackGenerator(style: .heavy).impactOccurred() }
    static func success() { UINotificationFeedbackGenerator().notificationOccurred(.success) }
    static func warn()    { UINotificationFeedbackGenerator().notificationOccurred(.warning) }
    static func tick()    { UISelectionFeedbackGenerator().selectionChanged() }
}
