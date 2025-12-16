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
        let oAuthRepository = OAuthRepository()
 
        // Auth & Session
        dependencies.authRepository = AuthRepository()
        dependencies.sessionRepository = SessionRepository()
        dependencies.profileRepository = ProfileRepository()
        dependencies.versionRepository = VersionRepository()
        
        let oAuthUseCase = makeOAuthUseCase(repository: oAuthRepository)
        dependencies.oAuthUseCase = oAuthUseCase
        dependencies.unifiedOAuthUseCase = UnifiedOAuthUseCase(
            oAuthUseCase: oAuthUseCase,
            sessionStoreRepository: SessionStoreRepository()
        )
        // Analytics
        dependencies.analyticsRepository = FirebaseAnalyticsRepository()
        
        // Travel
        dependencies.travelRepository = TravelRepository(
            remote: TravelRemoteDataSource(),
            local: TravelLocalDataSource()
        )
        
        // Expense
        dependencies.expenseRepository = ExpenseRepository(
            remote: ExpenseRemoteDataSource(),
            local: ExpenseLocalDataSource()
        )
        
        // TravelMember
        dependencies.travelMemberRepository = TravelMemberRepository(remote: TravelMemberRemoteDataSource())

        // Country & Exchange
        dependencies.countryRepository = CountryRepository(remote: CountryRemoteDataSource())
        dependencies.exchangeRateRepository = ExchangeRateRepository(remote: ExchangeRateRemoteDataSource())
        
        // Settlement
        dependencies.settlementRepository = SettlementRepository(remote: SettlementRemoteDataSource())
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
