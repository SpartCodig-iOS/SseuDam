//
//  TokenResult.swift
//  Domain
//
//  Created by Wonji Suh  on 11/27/25.
//

import Foundation

public struct TokenResult: Equatable {
    public let token: AuthTokens
    
    public init(token: AuthTokens) {
        self.token = token
    }
}
