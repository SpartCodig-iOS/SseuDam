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
    VStack {

      Text("test")
        .onTapGesture {
          store.send(.view(.googleButtonTapped))
        }

    }
    .background(Color.primary50)

//    VStack(spacing: 20) {
//      Image(systemName: "star.fill")
//        .imageScale(.large)
//        .foregroundStyle(.tint)
//
//      Text("Login Feature")
//        .font(.title)
//        .fontWeight(.bold)
//
//      SignInWithAppleButton(.signIn) { request in
//        let nonce = AppleLoginManger.shared.randomNonceString()
//        store.send(.view(.appleNonceGenerated(nonce)))
//        request.requestedScopes = [.fullName, .email]
//        request.nonce = AppleLoginManger.shared.sha256(nonce)
//      } onCompletion: { result in
//        store.send(.view(.appleSignIn(result)))
//      }
//      .frame(height: 50)
//      .disabled(store.isLoading)
//
//    }
//    .padding()
//    .navigationTitle("Login")
  }
}


extension LoginView {
  
}

#Preview {
  LoginView(store:  Store(
    initialState: LoginFeature.State(),
    reducer: {
      LoginFeature()
    }
  ))
}
