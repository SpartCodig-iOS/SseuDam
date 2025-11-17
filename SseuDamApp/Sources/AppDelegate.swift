import SwiftUI
import LoginFeature
import ComposableArchitecture
import Data
import Domain

@main
struct SseuDamApp: App {
    var body: some Scene {
        WindowGroup {
           LoginView(store:  Store(
            initialState: LoginFeature.State(),
            reducer: {
              LoginFeature()
            }
          ))
        }
    }
}
