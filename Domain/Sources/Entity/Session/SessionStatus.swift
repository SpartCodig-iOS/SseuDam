//
//  SessionStatus.swift
//  Domain
//
//  Created by Wonji Suh  on 11/25/25.
//

import Foundation

/// Session status returned from backend session validation.
public struct SessionStatus: Equatable {
    public let provider: SocialType
    public let sessionId: String
    public let status: String
    
    public init(
        provider: SocialType,
        sessionId: String,
        status: String
    ) {
        self.provider = provider
        self.sessionId = sessionId
        self.status = status
    }
}
