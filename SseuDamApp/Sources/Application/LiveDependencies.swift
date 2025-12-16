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
        // Auth & Session
        dependencies.authRepository = AuthRepository()
        dependencies.sessionRepository = SessionRepository()

        dependencies.oAuthRepository = OAuthRepository()
        dependencies.googleOAuthRepository = GoogleOAuthRepository()
        dependencies.appleOAuthRepository = AppleOAuthRepository()
        dependencies.kakaoOAuthRepository = KakaoOAuthRepository(
            presentationContextProvider: AppPresentationContextProvider()
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
        
        // Profile
        dependencies.profileRepository = ProfileRepository()
        
        // AppVersion
        dependencies.versionRepository = VersionRepository()
        
    }
}
