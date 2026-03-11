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

public class AppleOAuthProvider: AppleOAuthProviderProtocol, @unchecked Sendable {
    public let socialType: SocialType = .apple

    private let oAuthRepository: OAuthRepositoryProtocol
    private let appleRepository: AppleOAuthRepositoryProtocol

    /// DI를 위한 생성자 - Repository들을 한 번에 주입받음
    public init(
        oAuthRepository: OAuthRepositoryProtocol,
        appleRepository: AppleOAuthRepositoryProtocol
    ) {
        self.oAuthRepository = oAuthRepository
        self.appleRepository = appleRepository
    }

    public func signInWithCredential(
        credential: ASAuthorizationAppleIDCredential,
        nonce: String
    ) async throws -> UserProfile {
        guard let identityTokenData = credential.identityToken,
              let identityToken = String(data: identityTokenData, encoding: .utf8),
              let authCode = String(data: credential.authorizationCode ?? Data(), encoding: .utf8)
        else {
            throw AuthError.missingIDToken
        }

        let displayName = formatDisplayName(credential.fullName)
        Log.info("Apple sign-in credential received for \(displayName ?? "unknown user")")

        let profile = try await oAuthRepository.signIn(
            provider: .apple,
            idToken: identityToken,
            nonce: nonce,
            displayName: displayName,
            authorizationCode: authCode
        )
        Log.info("Supabase sign-in with Apple succeeded")
        return profile
    }

    public func signUp() async throws -> UserProfile {
        let payload = try await fetchPayload()
        Log.info("apple sign-in succeeded for \(payload.displayName ?? "unknown user")")

        let profile = try await oAuthRepository.signIn(
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

    private func fetchPayload() async throws -> OAuthSignInPayload {
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
