//
//  GoogleOAuthProvider.swift
//  Domain
//
//  Created by Wonji Suh on 12/17/25.
//

import Foundation
import Dependencies
import LogMacro

public class GoogleOAuthProvider: GoogleOAuthProviderProtocol, @unchecked Sendable {
    public let socialType: SocialType = .google

    private let oAuthRepository: OAuthRepositoryProtocol
    private let googleRepository: GoogleOAuthRepositoryProtocol

    /// DI를 위한 생성자 - Repository들을 한 번에 주입받음
    public init(
        oAuthRepository: OAuthRepositoryProtocol,
        googleRepository: GoogleOAuthRepositoryProtocol
    ) {
        self.oAuthRepository = oAuthRepository
        self.googleRepository = googleRepository
    }

  
    public func signUp() async throws -> UserProfile {
        let payload = try await fetchPayload()
        Log.info("google sign-in succeeded for \(payload.displayName ?? "unknown user")")

        let profile = try await oAuthRepository.signIn(
            provider: payload.provider,
            idToken: payload.idToken,
            nonce: payload.nonce,
            displayName: payload.displayName,
            authorizationCode: payload.authorizationCode
        )
        Log.info("Supabase sign-in with google succeeded")
        return profile
    }

    private func fetchPayload() async throws -> OAuthSignInPayload {
        let payload = try await googleRepository.signIn()
        return OAuthSignInPayload(
            provider: .google,
            idToken: payload.idToken,
            nonce: nil,
            displayName: payload.displayName,
            authorizationCode: payload.authorizationCode
        )
    }
}
