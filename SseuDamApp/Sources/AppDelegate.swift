import SwiftUI
import Swinject

@main
struct SseuDamApp: App {
    let container = DIContainer.shared.container

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
