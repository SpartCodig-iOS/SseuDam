//
//  GoogleOAuthProvider.swift
//  Domain
//
//  Created by Wonji Suh on 12/17/25.
//

import Foundation
import Dependencies
import LogMacro

public class GoogleOAuthProvider: OAuthProviderProtocol {
    public let socialType: SocialType = .google

    public init() {}

    // ✅ 기존 signUp 로직 그대로 (Dependencies 매개변수로 전달)
    public func signUp(
        repository: OAuthRepositoryProtocol,
        googleRepository: GoogleOAuthRepositoryProtocol
    ) async throws -> UserProfile {
        let payload = try await fetchPayload(googleRepository: googleRepository)
        Log.info("google sign-in succeeded for \(payload.displayName ?? "unknown user")")

        let profile = try await repository.signIn(
            provider: payload.provider,
            idToken: payload.idToken,
            nonce: payload.nonce,
            displayName: payload.displayName,
            authorizationCode: payload.authorizationCode
        )
        Log.info("Supabase sign-in with google succeeded")
        return profile
    }

    // ✅ 기존 fetchPayload 로직 그대로 (매개변수로 repository 전달)
    private func fetchPayload(googleRepository: GoogleOAuthRepositoryProtocol) async throws -> OAuthSignInPayload {
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