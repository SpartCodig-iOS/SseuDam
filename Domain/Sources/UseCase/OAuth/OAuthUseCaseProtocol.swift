//
//  OAuthUseCaseProtocol.swift
//  Domain
//
//  Created by Wonji Suh  on 11/17/25.
//

import Foundation
import AuthenticationServices

public protocol OAuthUseCaseProtocol {
    func signInWithApple(
        credential: ASAuthorizationAppleIDCredential,
        nonce: String
    ) async throws -> UserProfile
    
    func signUp(
        with provider: SocialType
    ) async throws -> UserProfile
}
