//
//  MockKakaoFinalizeRepository.swift
//  Domain
//
//  Created by Assistant on 12/5/25.
//

import Foundation

public final class MockKakaoFinalizeRepository: KakaoFinalizeRepositoryProtocol {
    public init() {}
    
    public func finalize(ticket: String) async throws -> AuthResult {
        let tokens = AuthTokens(
            authToken: "mock-kakao-auth-\(ticket.prefix(6))",
            accessToken: "mock-kakao-access-\(ticket.prefix(6))",
            refreshToken: "mock-kakao-refresh",
            sessionID: "mock-kakao-session"
        )
        return AuthResult(
            userId: "mock-kakao-user",
            name: "Mock Kakao",
            provider: .kakao,
            token: tokens
        )
    }
}
