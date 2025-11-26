import SwiftUI
import LoginFeature
import ComposableArchitecture
import Data
import Domain

@main
struct SseuDamApp: App {
    private let store = Store(initialState: AppFeature.State()) {
        AppFeature()
            ._printChanges()
            ._printChanges(.actionLabels)
    } withDependencies: {
        $0.loginUseCase = makeLoginUseCase()
        $0.signUpUseCase = makeSignUpUseCase()
    }

    var body: some Scene {
        WindowGroup {
            AppView(store: store)
        }
    }
}

private extension SseuDamApp {
    static func makeLoginUseCase() -> LoginUseCase {
        LoginUseCase(
            oAuth: OAuthUseCase(
              repository: OAuthRepository(),
                googleRepository: GoogleOAuthRepository(),
                appleRepository: AppleOAuthRepository()
            )
        )
    }

  static func makeSignUpUseCase() -> SignUpUseCase {
    SignUpUseCase(
      repository: SignUpRepository()
    )
  }
}

