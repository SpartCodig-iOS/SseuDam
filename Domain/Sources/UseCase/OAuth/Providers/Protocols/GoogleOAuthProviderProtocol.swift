//
//  GoogleOAuthProviderProtocol.swift
//  Domain
//
//  Created by Wonji Suh on 02/09/26.
//

import Foundation

/// Google-specific OAuth provider protocol
public protocol GoogleOAuthProviderProtocol: OAuthProviderProtocol, Sendable {
    func signUp() async throws -> UserProfile
}