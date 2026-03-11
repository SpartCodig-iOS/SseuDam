//
//  SessionStoreRepository.swift
//  Domain
//
//  Created by Wonji Suh on 12/11/25.
//

import Foundation
import Domain

/// Keychain + UserDefaults를 감싼 세션 저장소
public final class SessionStoreRepository: SessionStoreRepositoryProtocol, @unchecked Sendable {
    private enum Keys {
        static let socialType = "socialType"
        static let userId = "userId"
        static let sessionId = "sessionId"
    }

    private let keychainManager: KeychainManaging

    public init(keychainManager: KeychainManaging = KeychainManager.live) {
        self.keychainManager = keychainManager
    }

    public func save(tokens: AuthTokens, socialType: SocialType?, userId: String?) async {
        await keychainManager.saveTokens(
            accessToken: tokens.accessToken,
            refreshToken: tokens.refreshToken
        )

        // sessionId는 UserDefaults로 노출 (appStorage 연동)
        UserDefaults.standard.set(tokens.sessionID, forKey: Keys.sessionId)

        if let socialType {
            UserDefaults.standard.set(socialType.rawValue, forKey: Keys.socialType)
        }

        if let userId {
            UserDefaults.standard.set(userId, forKey: Keys.userId)
        }
    }

    public func loadTokens() async -> AuthTokens? {
        let tokens = await keychainManager.loadTokens()
        guard let access = tokens.accessToken,
              let refresh = tokens.refreshToken
        else { return nil }

        let sessionId = UserDefaults.standard.string(forKey: Keys.sessionId) ?? ""
        return AuthTokens(
            authToken: access, // authToken 필드가 없을 수 있어 access로 채움
            accessToken: access,
            refreshToken: refresh,
            sessionID: sessionId
        )
    }

    public func loadSocialType() async -> SocialType? {
        guard let raw = UserDefaults.standard.string(forKey: Keys.socialType) else { return nil }
        return SocialType(rawValue: raw)
    }

    public func loadUserId() async -> String? {
        UserDefaults.standard.string(forKey: Keys.userId)
    }

    public func clearAll() async {
        await keychainManager.clearAll()
        UserDefaults.standard.removeObject(forKey: Keys.sessionId)
        UserDefaults.standard.removeObject(forKey: Keys.socialType)
        UserDefaults.standard.removeObject(forKey: Keys.userId)
    }
}
