//
//  LiveDependencies.swift
//  SseuDamApp
//
//  Created by 홍석현 on 12/8/25.
//

import Foundation
import Dependencies
import Data
import Domain

public enum LiveDependencies {
  @MainActor public static func register(_ dependencies: inout DependencyValues) {
        // Repository 인스턴스 생성 (재사용)
        let travelRepository = TravelRepository(remote: TravelRemoteDataSource())
        let expenseRepository = ExpenseRepository(
            remote: ExpenseRemoteDataSource(),
            local: ExpenseLocalDataSource()
        )
        let travelMemberRepository = TravelMemberRepository(remote: TravelMemberRemoteDataSource())
        let authRepository = AuthRepository()
        let oAuthRepository = OAuthRepository()
        let countryRepository = CountryRepository(remote: CountryRemoteDataSource())
        let exchangeRateRepository = ExchangeRateRepository(remote: ExchangeRateRemoteDataSource())
        let settlementRepository = SettlementRepository(remote: SettlementRemoteDataSource())
        let profileRepository = ProfileRepository()
        let versionRepository = VersionRepository()

        // Auth & Session
        let oAuthUseCase = makeOAuthUseCase(repository: oAuthRepository)
        dependencies.oAuthUseCase = oAuthUseCase
        dependencies.unifiedOAuthUseCase = UnifiedOAuthUseCase(
            oAuthUseCase: oAuthUseCase,
            authRepository: authRepository,
            sessionStoreRepository: SessionStoreRepository()
        )
        dependencies.sessionUseCase = SessionUseCase(repository: SessionRepository())
        dependencies.authUseCase = AuthUseCase(repository: authRepository)
        dependencies.profileUseCase = ProfileUseCase(repository: profileRepository)
        dependencies.versionUseCase = VersionUseCase(repository: versionRepository)

        // Analytics
//        dependencies.analyticsUseCase = AnalyticsUseCase(repository: FirebaseAnalyticsRepository())

        // Travel
        dependencies.fetchTravelsUseCase = FetchTravelsUseCase(repository: travelRepository)
        dependencies.createTravelUseCase = CreateTravelUseCase(repository: travelRepository)
        dependencies.fetchTravelDetailUseCase = FetchTravelDetailUseCase(repository: travelRepository)
        dependencies.updateTravelUseCase = UpdateTravelUseCase(repository: travelRepository)
        dependencies.deleteTravelUseCase = DeleteTravelUseCase(repository: travelRepository)

        // Expense
        dependencies.expenseRepository = expenseRepository
        dependencies.fetchTravelExpenseUseCase = FetchTravelExpenseUseCase(repository: expenseRepository)
        dependencies.createExpenseUseCase = CreateExpenseUseCase(repository: expenseRepository)
        dependencies.updateExpenseUseCase = UpdateExpenseUseCase(repository: expenseRepository)
        dependencies.deleteExpenseUseCase = DeleteExpenseUseCase(repository: expenseRepository)

        // TravelMember
        dependencies.joinTravelUseCase = JoinTravelUseCase(repository: travelMemberRepository)
        dependencies.delegateOwnerUseCase = DelegateOwnerUseCase(repository: travelMemberRepository)
        dependencies.deleteTravelMemberUseCase = DeleteTravelMemberUseCase(repository: travelMemberRepository)
        dependencies.leaveTravelUseCase = LeaveTravelUseCase(repository: travelMemberRepository)
        dependencies.fetchMemberUseCase = FetchMemberUseCase(repository: travelMemberRepository)

        // Country & Exchange
        dependencies.fetchCountriesUseCase = FetchCountriesUseCase(repository: countryRepository)
        dependencies.fetchExchangeRateUseCase = FetchExchangeRateUseCase(repository: exchangeRateRepository)

        // Settlement
        dependencies.fetchSettlementUseCase = FetchSettlementUseCase(repository: settlementRepository)
        dependencies.calculateSettlementUseCase = CalculateSettlementUseCase()
    }
    
    // MARK: - Factory Methods
    @MainActor
    private static func makeOAuthUseCase(repository: OAuthRepository) -> OAuthUseCaseProtocol {
        OAuthUseCase(
            repository: repository,
            googleRepository: GoogleOAuthRepository(),
            appleRepository: AppleOAuthRepository(),
            kakaoRepository: KakaoOAuthRepository(
                presentationContextProvider: AppPresentationContextProvider()
            )
        )
    }
}
