//
//  AppleOAuthPayload.swift
//  Domain
//
//  Created by Wonji Suh  on 11/17/25.
//

import Foundation

public struct AppleOAuthPayload {
    public let idToken: String
    public let authorizationCode: String?
    public let displayName: String?
    public let nonce: String

    public init(
        idToken: String,
        authorizationCode: String?,
        displayName: String?,
        nonce: String
    ) {
        self.idToken = idToken
        self.authorizationCode = authorizationCode
        self.displayName = displayName
        self.nonce = nonce
    }
}

public enum AppleSignInError: Error, LocalizedError {
    case missingIDToken
    case missingNonce
    case userCancelled
    case authorizationFailed(String)

    public var errorDescription: String? {
        switch self {
        case .missingIDToken:
            return "Apple ID 토큰이 없습니다"
        case .missingNonce:
            return "Nonce가 없습니다"
        case .userCancelled:
            return "사용자가 로그인을 취소했습니다"
        case .authorizationFailed(let message):
            return "Apple 로그인 실패: \(message)"
        }
    }
}