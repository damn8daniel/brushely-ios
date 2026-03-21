import SwiftUI
import SwiftData

@main
struct BrushelyApp: App {
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .preferredColorScheme(.dark)
        }
        .modelContainer(for: BrushingSession.self)
    }
}
