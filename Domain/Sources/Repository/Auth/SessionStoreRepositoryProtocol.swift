//
//  SessionStoreRepositoryProtocol.swift
//  Domain
//
//  Created by Wonji Suh on 12/11/25.
//

import Foundation

public protocol SessionStoreRepositoryProtocol {
    func save(tokens: AuthTokens, socialType: SocialType?, userId: String?)
    func loadTokens() -> AuthTokens?
    func loadSocialType() -> SocialType?
    func loadUserId() -> String?
    func clearAll()
}
