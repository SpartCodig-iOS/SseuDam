//
//  OAuthUseCaseProtocol.swift
//  Domain
//
//  Created by Wonji Suh  on 11/17/25.
//

import Foundation
import AuthenticationServices


public protocol OAuthUseCaseProtocol {
  func signInWithAppleOnce(
    credential: ASAuthorizationAppleIDCredential,
    nonce: String
  ) async throws -> UserEntity
  func signUpWithAppleSuperBase() async throws -> UserEntity
  func signUpWithGoogleSuperBase() async throws -> UserEntity
}
