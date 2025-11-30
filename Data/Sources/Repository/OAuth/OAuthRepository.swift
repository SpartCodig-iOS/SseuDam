//
//  OAuthRepository.swift
//  Data
//
//  Created by Wonji Suh  on 11/17/25.
//

import Domain
import Supabase
import LogMacro
import Moya
import NetworkService

public final class OAuthRepository: OAuthRepositoryProtocol {
    // FIXME: SupabaseClientProviding이 feature/travel-setting-ui 브랜치에만 있음
    // private let supabaseprovider: SupabaseClientProviding
    // private var client: SupabaseClient { supabaseprovider.client }
    private var provider: MoyaProvider<OAuthAPITarget>

    public init(
        provider: MoyaProvider<OAuthAPITarget> = MoyaProvider<OAuthAPITarget>.default,
    ) {
        // self.supabaseprovider = SupabaseClientProvider.shared
        self.provider = provider
    }
    
    public func signIn(
        provider: SocialType,
        idToken: String,
        nonce: String?,
        displayName: String?,
        authorizationCode: String?
    ) async throws -> UserProfile {
        // FIXME: SupabaseClient 임시 주석 처리
        fatalError("SupabaseClientProviding 구현 필요 - feature/travel-setting-ui 브랜치 참고")

        // let credentials = OpenIDConnectCredentials(
        //     provider: provider.openIDProvider,
        //     idToken: idToken,
        //     nonce: nonce
        // )
        //
        // let session = try await client.auth.signInWithIdToken(credentials: credentials)
        // Log.info("\(provider.rawValue) signInWithIdToken completed. \(session.accessToken)")
        //
        // try await updateDisplayNameIfNeeded(displayName)
        // return session.toDomain(authorizationCode: authorizationCode)
    }

    public func updateUserDisplayName(_ name: String) async throws {
        // FIXME: SupabaseClient 임시 주석 처리
        fatalError("SupabaseClientProviding 구현 필요 - feature/travel-setting-ui 브랜치 참고")

        // try await client.auth.update(
        //     user: UserAttributes(data: ["display_name": .string(name)])
        // )
    }

    // MARK: - Private
    private func updateDisplayNameIfNeeded(_ displayName: String?) async throws {
        // FIXME: SupabaseClient 임시 주석 처리
        // guard let displayName = displayName?.trimmingCharacters(in: .whitespacesAndNewlines),
        //       !displayName.isEmpty
        // else { return }
        //
        // try await updateUserDisplayName(displayName)
        // Log.info("Updated Supabase display_name to \(displayName)")
    }
}
