import SwiftUI
import SwiftData

@main
struct VikarTimeApp: App {

    var body: some Scene {

        WindowGroup {
            MainTabView()
        }
        .modelContainer(
            for: WorkEntry.self
        )
    }
}
