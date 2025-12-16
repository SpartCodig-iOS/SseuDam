//
//  AppleOAuthProtocol.swift
//  Domain
//
//  Created by Wonji Suh  on 11/17/25.
//

import Foundation
import Dependencies

public protocol AppleOAuthRepositoryProtocol {
    func signIn() async throws -> AppleOAuthPayload
}

// MARK: - Dependencies
public struct AppleOAuthRepositoryDependency: DependencyKey {
    public static var liveValue:  AppleOAuthRepositoryProtocol {
        fatalError("AppleOAuthServiceDependency liveValue not implemented")
    }
    public static var previewValue:  AppleOAuthRepositoryProtocol = MockAppleOAuthRepository()
    public static var testValue:  AppleOAuthRepositoryProtocol = MockAppleOAuthRepository()
}

public extension DependencyValues {
    var appleOAuthRepository:  AppleOAuthRepositoryProtocol {
        get { self[AppleOAuthRepositoryDependency.self] }
        set { self[AppleOAuthRepositoryDependency.self] = newValue }
    }
}
