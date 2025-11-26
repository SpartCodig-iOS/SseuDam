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
        $0.fetchTravelsUseCase = makeFetchTravelsUseCase()
        $0.createTravelUseCase = makeCreateTravelUseCase()
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

    static func makeFetchTravelsUseCase() -> FetchTravelsUseCase {
        FetchTravelsUseCase(
            repository: TravelRepository(
                remote: TravelRemoteDataSource()
            )
        )
    }

    static func makeCreateTravelUseCase() -> CreateTravelUseCase {
        CreateTravelUseCase(
            repository: TravelRepository(
                remote: TravelRemoteDataSource()
            )
        )
    }
}

