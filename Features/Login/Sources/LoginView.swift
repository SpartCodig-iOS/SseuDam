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
import AuthenticationServices
import CryptoKit


public struct LoginView: View {
  @Bindable var store: StoreOf<LoginFeature>


  public init(
    store: StoreOf<LoginFeature>
  ) {
    self.store = store
  }

  public var body: some View {
    VStack(spacing: 20) {
      Image(systemName: "star.fill")
        .imageScale(.large)
        .foregroundStyle(.tint)

      Text("Login Feature")
        .font(.title)
        .fontWeight(.bold)

      // Apple Sign In Button
      SignInWithAppleButton(.signIn) { request in
        let nonce = AppleLoginManger.shared.randomNonceString()
        store.send(.view(.appleNonceGenerated(nonce)))
        request.requestedScopes = [.fullName, .email]
        request.nonce = AppleLoginManger.shared.sha256(nonce)
      } onCompletion: { result in
        store.send(.view(.appleSignIn(result)))
      }
      .frame(height: 50)
      .disabled(store.isLoading)

      // Google Login Button
      Button {
        store.send(.view(.googleButtonTapped))
      } label: {
        HStack {
          Image(systemName: "g.circle.fill")
          Text("Google로 로그인")
            .fontWeight(.semibold)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
      }
      .buttonStyle(.borderedProminent)
      .tint(.orange)
      .disabled(store.isLoading)

      if store.isLoading {
        ProgressView("로그인 중...")
      }

      if let statusMessage = store.statusMessage {
        Text(statusMessage)
          .font(.footnote)
          .foregroundColor(.blue)
          .multilineTextAlignment(.center)
      }
    }
    .padding()
    .navigationTitle("Login")
  }
}

#Preview {
  NavigationView {
    LoginView(store:  Store(
      initialState: LoginFeature.State(),
      reducer: {
        LoginFeature()
      },
      withDependencies: {
        $0.oAuthUseCase = OAuthUseCase(
          repository: OAuthRepository(),
          googleService: GoogleOAuthService(),
          appleService: AppleOAuthService()
        )
      }
    ))
  }
}
