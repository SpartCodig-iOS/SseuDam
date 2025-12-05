//
//  LoginDemoApp.swift
//  TestApp
//
//  Created by TestDev on 09-11-25.
//  Copyright © 2025 TestDev. All rights reserved.
//

import SwiftUI
import LoginFeature
import Dependencies
import ComposableArchitecture
import Domain

@main
struct LoginDemoApp: App {
    var body: some Scene {
        WindowGroup {
            withDependencies {
              $0.oAuthUseCase = OAuthUseCase(
                repository: MockOAuthRepository(),
                googleRepository: MockGoogleOAuthRepository(),
                appleRepository: MockAppleOAuthRepository(),
                kakaoRepository: MockKakaoOAuthRepository()
              )
            } operation: {
                NavigationView {
                  LoginView(store: .init(initialState: LoginFeature.State(), reducer: {
                    LoginFeature()
                  }))
                }
            }
        }
    }
}
