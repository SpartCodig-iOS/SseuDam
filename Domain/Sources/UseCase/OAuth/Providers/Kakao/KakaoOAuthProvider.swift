//
//  KakaoOAuthProvider.swift
//  Domain
//
//  Created by Wonji Suh on 12/17/25.
//

import Foundation
import Dependencies
import LogMacro

public class KakaoOAuthProvider: OAuthProviderProtocol {
    public let socialType: SocialType = .kakao

    public init() {}

    public func signUp(kakaoRepository: KakaoOAuthRepositoryProtocol) async throws -> UserProfile {
        let kakaoPayload = try await kakaoRepository.signIn()
        let tokens = AuthTokens(
            authToken: kakaoPayload.authorizationCode ?? "",
            accessToken: kakaoPayload.accessToken,
            refreshToken: kakaoPayload.refreshToken ?? "",
            sessionID: ""
        )
        return UserProfile(
            id: kakaoPayload.authorizationCode ?? UUID().uuidString,
            email: nil,
            displayName: kakaoPayload.displayName,
            provider: .kakao,
            tokens: tokens,
            authCode: kakaoPayload.authorizationCode,
            codeVerifier: kakaoPayload.codeVerifier
        )
    }
}
