//
//  AuthEntity.swift
//  Domain
//
//  Created by Wonji Suh  on 11/24/25.
//

import Foundation

public struct AuthResult: Equatable {
    public let name: String
    public let provider: SocialType
    public var token:  AuthTokens
    
    public init(
        name: String,
        provider: SocialType,
        token: AuthTokens
    ) {
        self.name = name
        self.provider = provider
        self.token = token
    }
    
}

