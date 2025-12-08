//
//  AuthTokens.swift
//  Domain
//
//  Created by Wonji Suh  on 11/17/25.
//


import Foundation

public struct AuthTokens: Equatable, Hashable {
    public var authToken: String
    public let accessToken: String
    public let refreshToken: String?
    public let sessionID: String
    
    public init(
        authToken: String,
        accessToken: String,
        refreshToken: String?,
        sessionID: String
    ) {
        self.authToken = authToken
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.sessionID = sessionID
    }
}

public extension AuthTokens {
    /// Kakao처럼 accessToken이 비어있을 때 authToken(혹은 authorizationCode)을 대신 사용하기 위한 헬퍼
    var authCodeTokenFallback: String {
        return accessToken.isEmpty ? authToken : accessToken
    }
}
