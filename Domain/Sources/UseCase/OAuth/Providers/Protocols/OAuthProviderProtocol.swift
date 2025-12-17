//
//  OAuthProviderProtocol.swift
//  Domain
//
//  Created by Wonji Suh on 12/17/25.
//

import Foundation
import AuthenticationServices

public protocol OAuthProviderProtocol {
    var socialType: SocialType { get }
}

// Apple 전용 프로토콜
public protocol AppleOAuthProviderProtocol: OAuthProviderProtocol {
    func signInWithCredential(
        credential: ASAuthorizationAppleIDCredential,
        nonce: String,
        repository: OAuthRepositoryProtocol
    ) async throws -> UserProfile

    func signUp(
        repository: OAuthRepositoryProtocol,
        appleRepository: AppleOAuthRepositoryProtocol
    ) async throws -> UserProfile
}