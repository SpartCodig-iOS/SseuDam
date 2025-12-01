//
//  UserEntity.swift
//  Domain
//
//  Created by Wonji Suh  on 11/17/25.
//

public struct UserProfile: Equatable, Identifiable {

    public let id: String
    public let email: String?
    public let displayName: String?
    public let provider: SocialType
    public var tokens: AuthTokens
    public let authCode: String?

    public init(
        id: String,
        email: String? = nil,
        displayName: String? = nil,
        provider: SocialType,
        tokens: AuthTokens,
        authCode: String? = nil
    ) {
        self.id = id
        self.email = email
        self.displayName = displayName
        self.provider = provider
        self.tokens = tokens
        self.authCode = authCode
    }
}
