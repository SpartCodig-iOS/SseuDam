import SwiftUI
import LoginFeature
import ComposableArchitecture
import Data
import Domain
import Foundation

@main
struct SseuDamApp: App {

    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

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
        $0.sessionUseCase = makeSessionUseCase()
        $0.fetchTravelsUseCase = makeFetchTravelsUseCase()
        $0.createTravelUseCase = makeCreateTravelUseCase()
        $0.authUseCase = makeAuthUseCase()
        $0.fetchTravelDetailUseCase = makeFetchTravelDetailUseCase()
        $0.fetchTravelExpenseUseCase = makeFetchTravelExpenseUseCase()
        $0.createExpenseUseCase = makeCreateExpenseUseCase()
        $0.updateExpenseUseCase = makeUpdateExpenseUseCase()
        $0.deleteExpenseUseCase = makeDeleteExpenseUseCase()
        $0.expenseRepository = makeExpenseRepository()
        $0.profileUseCase = makeProfileUseCase()
        $0.joinTravelUseCase = makeJoinTravelUseCase()
        $0.delegateOwnerUseCase = makeDelegateOwnerUseCase()
        $0.deleteTravelMemberUseCase = makeDeleteTravelMemberUseCase()
        $0.leaveTravelUseCase = makeLeaveTravelUseCase()
        $0.updateTravelUseCase = makeUpdateTravelUseCase()
        $0.deleteTravelUseCase = makeDeleteTravelUseCase()
        $0.fetchCountriesUseCase = makeFetchCountriesUseCase()
        $0.fetchExchangeRateUseCase = makeFetchExchangeRateUseCase()
        $0.versionUseCase = makeVersionUseCase()
    }

    var body: some Scene {
        WindowGroup {
            AppView(
                store: store
            )
            .onOpenURL { url in
                // Kakao 딥링크(ticket/code) 저장
                handleKakaoTicket(from: url)
                store.send(.view(.handleDeepLink(url.absoluteString)))
            }
            .onContinueUserActivity(NSUserActivityTypeBrowsingWeb) { userActivity in
                if let url = userActivity.webpageURL {
                    store.send(.view(.handleDeepLink(url.absoluteString)))
                }
            }
        }
    }
}

private extension SseuDamApp {
    static func makeLoginUseCase() -> LoginUseCaseProtocol {
        LoginUseCase(repository: LoginRepository())
    }

    static func makeOAuthUseCase() -> OAuthUseCaseProtocol {
        OAuthUseCase(
            repository: OAuthRepository(),
            googleRepository: GoogleOAuthRepository(),
            appleRepository: AppleOAuthRepository(),
            kakaoRepository: KakaoOAuthRepository(presentationContextProvider: AppPresentationContextProvider())
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
            loginRepository: LoginRepository(),
            kakaoFinalizeRepository: KakaoFinalizeRepository()
        )
    }

    static func makeSessionUseCase() -> SessionUseCaseProtocol {
        SessionUseCase(repository: SessionRepository())
    }

    static func makeAuthUseCase() -> AuthUseCaseProtocol {
        AuthUseCase(repository: AuthRepository())
    }

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

    static func makeFetchTravelDetailUseCase() -> FetchTravelDetailUseCaseProtocol {
        FetchTravelDetailUseCase(
            repository: TravelRepository(
                remote: TravelRemoteDataSource()
            )
        )
    }

    static func makeFetchTravelExpenseUseCase() -> FetchTravelExpenseUseCaseProtocol {
        FetchTravelExpenseUseCase(
            repository: makeExpenseRepository()
        )
    }

    static func makeCreateExpenseUseCase() -> CreateExpenseUseCase {
        CreateExpenseUseCase(
            repository: makeExpenseRepository()
        )
    }

    static func makeUpdateExpenseUseCase() -> UpdateExpenseUseCase {
        UpdateExpenseUseCase(
            repository: makeExpenseRepository()
        )
    }

    static func makeDeleteExpenseUseCase() -> DeleteExpenseUseCase {
        DeleteExpenseUseCase(
            repository: makeExpenseRepository()
        )
    }

    static func makeExpenseRepository() -> ExpenseRepositoryProtocol {
        ExpenseRepository(
            remote: ExpenseRemoteDataSource()
        )
    }

    static func makeProfileUseCase() -> ProfileUseCaseProtocol {
        ProfileUseCase(repository: ProfileRepository())
    }

    static func makeJoinTravelUseCase() -> JoinTravelUseCaseProtocol {
        JoinTravelUseCase(
            repository: TravelMemberRepository(
                remote: TravelMemberRemoteDataSource()
            )
        )
    }

    static func makeDelegateOwnerUseCase() -> DelegateOwnerUseCaseProtocol {
        DelegateOwnerUseCase(
            repository: TravelMemberRepository(
                remote: TravelMemberRemoteDataSource()
            )
        )
    }

    static func makeDeleteTravelMemberUseCase() -> DeleteTravelMemberUseCaseProtocol {
        DeleteTravelMemberUseCase(
            repository: TravelMemberRepository(
                remote: TravelMemberRemoteDataSource()
            )
        )
    }

    static func makeLeaveTravelUseCase() -> LeaveTravelUseCaseProtocol {
        LeaveTravelUseCase(
            repository: TravelMemberRepository(
                remote: TravelMemberRemoteDataSource()
            )
        )
    }

    static func makeUpdateTravelUseCase() -> UpdateTravelUseCaseProtocol {
        UpdateTravelUseCase(
            repository: TravelRepository(
                remote: TravelRemoteDataSource()
            )
        )
    }

    static func makeDeleteTravelUseCase() -> DeleteTravelUseCaseProtocol {
        DeleteTravelUseCase(
            repository: TravelRepository(
                remote: TravelRemoteDataSource()
            )
        )
    }

    static func makeFetchCountriesUseCase() -> FetchCountriesUseCaseProtocol {
        FetchCountriesUseCase(
            repository: CountryRepository(
                remote: CountryRemoteDataSource()
            )
        )
    }

    static func makeFetchExchangeRateUseCase() -> FetchExchangeRateUseCaseProtocol {
        FetchExchangeRateUseCase(
            repository: ExchangeRateRepository(
                remote: ExchangeRateRemoteDataSource()
            )
        )
    }

    static func makeVersionUseCase() -> VersionUseCaseProtocol {
        VersionUseCase(
            repository: VersionRepository()
        )
    }
}
