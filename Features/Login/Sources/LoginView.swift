//
//  LoginView.swift
//  TestApp
//
//  Created by TestDev on 09-11-25.
//  Copyright © 2025 TestDev. All rights reserved.
//

import SwiftUI
import DesignSystem
import ComposableArchitecture
import Domain
import Data
import Dependencies

public struct LoginView: View {
    public init() {}

  public var body: some View {
        withDependencies {
            $0.googleOAuthService = GoogleOAuthService()
            $0.oAuthRepository = OAuthRepository()
        } operation: {
            LoginViewContent()
        }
    }
}

private struct LoginViewContent: View {
    @Dependency(\.oAuthRepository) private var repository
    @Dependency(\.googleOAuthService) private var googleService

    var body: some View {
        VStack {
            Image(systemName: "star.fill")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Login Feature")
                .font(.title)
                .fontWeight(.bold)
                .onTapGesture {
                  Task {
                    // 여기서 직접 usecase를 만들어서 사용
                    let useCase = OAuthUseCase(
                        repository: repository,
                        googleService: googleService
                    )
                    try await useCase.signUpWithGoogleSuperBase()
                  }
                }
        }
        .padding()
        .navigationTitle("Login")
    }
}

#Preview {
    NavigationView {
        LoginView()
    }
}
