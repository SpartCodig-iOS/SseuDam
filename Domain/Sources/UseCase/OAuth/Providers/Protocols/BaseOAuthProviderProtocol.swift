//
//  BaseOAuthProviderProtocol.swift
//  Domain
//
//  Created by Wonji Suh on 02/09/26.
//

import Foundation

/// Base protocol for all OAuth providers
public protocol OAuthProviderProtocol {
    var socialType: SocialType { get }
}