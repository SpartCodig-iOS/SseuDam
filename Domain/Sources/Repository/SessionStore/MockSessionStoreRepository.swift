//
//  MockSessionStoreRepository.swift
//  DomainTests
//
//  Created by Wonji Suh  on 12/17/25.
//

import Foundation

final class MockSessionStoreRepository: SessionStoreRepositoryProtocol, @unchecked Sendable {
    private var savedTokens: AuthTokens?
    private var savedSocialType: SocialType?
    private var savedUserId: String?
    private(set) var didClear = false

    func save(tokens: AuthTokens, socialType: SocialType?, userId: String?) async {
        savedTokens = tokens
        savedSocialType = socialType
        savedUserId = userId
    }

    func loadTokens() async -> AuthTokens? { savedTokens }
    func loadSocialType() async -> SocialType? { savedSocialType }
    func loadUserId() async -> String? { savedUserId }

    func clearAll() async {
        didClear = true
        savedTokens = nil
        savedSocialType = nil
        savedUserId = nil
    }
}
