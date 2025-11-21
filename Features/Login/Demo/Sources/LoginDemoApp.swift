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
import Domain
import Data

@main
struct LoginDemoApp: App {
    var body: some Scene {
        WindowGroup {
            withDependencies {
                $0.oAuthRepository = OAuthRepository()
                $0.googleOAuthService = GoogleOAuthService()
                $0.oAuthUseCase = OAuthUseCase(
                    repository: OAuthRepository(),
                    googleService: GoogleOAuthService()
                )
            } operation: {
                NavigationView {
                    LoginView()
                }
            }
        }
    }
}