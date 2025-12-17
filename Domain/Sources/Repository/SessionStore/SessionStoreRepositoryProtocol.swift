//
//  SessionStoreRepositoryProtocol.swift
//  Domain
//
//  Created by Wonji Suh on 12/11/25.
//

import Foundation
import ComposableArchitecture

public protocol SessionStoreRepositoryProtocol: Sendable {
    func save(tokens: AuthTokens, socialType: SocialType?, userId: String?) async
    func loadTokens() async -> AuthTokens?
    func loadSocialType() async -> SocialType?
    func loadUserId() async -> String?
    func clearAll() async
}


public struct SessionStoreRepositoryDependency: DependencyKey {
    public static var liveValue: SessionStoreRepositoryProtocol {
        fatalError("AuthRepositoryDependency liveValue not implemented")
    }
    public static var previewValue: SessionStoreRepositoryProtocol = MockSessionStoreRepository()
    public static var testValue: SessionStoreRepositoryProtocol = MockSessionStoreRepository()
}

public extension DependencyValues {
    var sessionStoreRepository: SessionStoreRepositoryProtocol {
        get { self[SessionStoreRepositoryDependency.self] }
        set { self[SessionStoreRepositoryDependency.self] = newValue }
    }
}
