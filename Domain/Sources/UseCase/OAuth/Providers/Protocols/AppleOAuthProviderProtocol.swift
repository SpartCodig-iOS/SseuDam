//
//  AppleOAuthProviderProtocol.swift
//  Domain
//
//  Created by Wonji Suh on 02/09/26.
//

import Foundation
import AuthenticationServices

/// Apple-specific OAuth provider protocol
public protocol AppleOAuthProviderProtocol: OAuthProviderProtocol, Sendable {
    func signInWithCredential(
        credential: ASAuthorizationAppleIDCredential,
        nonce: String
    ) async throws -> UserProfile

    func signUp() async throws -> UserProfile
}