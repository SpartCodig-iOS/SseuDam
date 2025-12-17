//
//  AppleOAuthProvider.swift
//  Domain
//
//  Created by Wonji Suh on 12/17/25.
//

import Foundation
import Dependencies
import LogMacro
import AuthenticationServices

public class AppleOAuthProvider: AppleOAuthProviderProtocol {
    public let socialType: SocialType = .apple

    public init() {}

    public func signInWithCredential(
        credential: ASAuthorizationAppleIDCredential,
        nonce: String,
        repository: OAuthRepositoryProtocol
    ) async throws -> UserProfile {
        guard let identityTokenData = credential.identityToken,
              let identityToken = String(data: identityTokenData, encoding: .utf8),
              let authCode = String(data: credential.authorizationCode ?? Data(), encoding: .utf8)
        else {
            throw AuthError.missingIDToken
        }

        let displayName = formatDisplayName(credential.fullName)
        Log.info("Apple sign-in credential received for \(displayName ?? "unknown user")")

        let profile = try await repository.signIn(
            provider: .apple,
            idToken: identityToken,
            nonce: nonce,
            displayName: displayName,
            authorizationCode: authCode
        )
        Log.info("Supabase sign-in with Apple succeeded")
        return profile
    }

    public func signUp(
        repository: OAuthRepositoryProtocol,
        appleRepository: AppleOAuthRepositoryProtocol
    ) async throws -> UserProfile {
        let payload = try await fetchPayload(appleRepository: appleRepository)
        Log.info("apple sign-in succeeded for \(payload.displayName ?? "unknown user")")

        let profile = try await repository.signIn(
            provider: payload.provider,
            idToken: payload.idToken,
            nonce: payload.nonce,
            displayName: payload.displayName,
            authorizationCode: payload.authorizationCode
        )
        Log.info("Supabase sign-in with apple succeeded")
        return profile
    }

    private func formatDisplayName(_ components: PersonNameComponents?) -> String? {
        guard let components else { return nil }
        let formatter = PersonNameComponentsFormatter()
        let name = formatter.string(from: components).trimmingCharacters(in: .whitespacesAndNewlines)
        return name.isEmpty ? nil : name
    }

    private func fetchPayload(appleRepository: AppleOAuthRepositoryProtocol) async throws -> OAuthSignInPayload {
        let payload = try await appleRepository.signIn()
        return OAuthSignInPayload(
            provider: .apple,
            idToken: payload.idToken,
            nonce: payload.nonce,
            displayName: payload.displayName,
            authorizationCode: payload.authorizationCode
        )
    }
}
