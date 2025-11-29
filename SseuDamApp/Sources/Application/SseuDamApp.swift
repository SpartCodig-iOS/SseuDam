import SwiftUI
import LoginFeature
import ComposableArchitecture
import Data
import Domain

@main
struct SseuDamApp: App {
    private let store = Store(
        initialState: AppFeature.State()
    ) {
        AppFeature()
            ._printChanges()
            ._printChanges(
                .actionLabels
            )
    } withDependencies: {
        $0.loginUseCase = makeLoginUseCase()
        $0.oAuthUseCase = makeOAuthUseCase()
        $0.signUpUseCase = makeSignUpUseCase()
        $0.unifiedOAuthUseCase = makeUnifiedOAuthUseCase()
        
        //Travel
        $0.fetchTravelsUseCase = makeFetchTravelsUseCase()
        $0.createTravelUseCase = makeCreateTravelUseCase()
    }
    
    var body: some Scene {
        WindowGroup {
            AppView(
                store: store
            )
        }
    }
}

private extension SseuDamApp {
    static func makeLoginUseCase() -> LoginUseCaseProtocol {
       LoginUseCase(repository: LoginRepository())

    }
}

  static func makeOAuthUseCase() -> OAuthUseCaseProtocol {
    OAuthUseCase(
      repository: OAuthRepository(),
        googleRepository: GoogleOAuthRepository(),
        appleRepository: AppleOAuthRepository()
    )
  }

  static func makeSignUpUseCase() -> SignUpUseCaseProtocol {
    SignUpUseCase(
      repository: SignUpRepository()
    )
  }

  static func makeUnifiedOAuthUseCase() -> UnifiedOAuthUseCase {
    UnifiedOAuthUseCase(
      oAuthUseCase: makeOAuthUseCase(),
      signUpRepository: SignUpRepository(),
      loginRepository: LoginRepository()
    )
  }

  //Travel
  static func makeFetchTravelsUseCase() -> FetchTravelsUseCaseProtocol {
        FetchTravelsUseCase(
            repository: TravelRepository(
                remote: TravelRemoteDataSource()
            )
        )
    }

    static func makeCreateTravelUseCase() -> CreateTravelUseCaseProtocol {
        CreateTravelUseCase(
            repository: TravelRepository(
                remote: TravelRemoteDataSource()
            )
        )
    }
}
