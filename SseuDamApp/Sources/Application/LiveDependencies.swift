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
    @MainActor
    public static func register(_ dependencies: inout DependencyValues) {
        // ✅ DI 패턴으로 변경된 의존성들 (순서 중요!)
        dependencies.keychainManager = KeychainManager.live

        // Repository 먼저 등록
        dependencies.authRepository = AuthRepository()
        dependencies.sessionRepository = SessionRepository()

        dependencies.oAuthRepository = OAuthRepository()
        dependencies.googleOAuthRepository = GoogleOAuthRepository()
        dependencies.appleOAuthRepository = AppleOAuthRepository()
        dependencies.kakaoOAuthRepository = KakaoOAuthRepository(
            presentationContextProvider: AppPresentationContextProvider()
        )
        dependencies.sessionStoreRepository = SessionStoreRepository()

        // ✅ Provider 등록 (Repository 의존성 주입)
        dependencies.appleOAuthProvider = AppleOAuthProvider(
            oAuthRepository: dependencies.oAuthRepository,
            appleRepository: dependencies.appleOAuthRepository
        )

        dependencies.googleOAuthProvider = GoogleOAuthProvider(
            oAuthRepository: dependencies.oAuthRepository,
            googleRepository: dependencies.googleOAuthRepository
        )

        // Analytics
        dependencies.analyticsRepository = AnalyticsRepository()
        
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
        
        // Profile
        dependencies.profileRepository = ProfileRepository()
        
        // AppVersion
        dependencies.versionRepository = VersionRepository()
        
    }
}
