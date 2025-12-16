//
//  GoogleOAuthRepositoryProtocol.swift
//  Domain
//
//  Created by Wonji Suh  on 11/17/25.
//

import Foundation
import Dependencies

public protocol GoogleOAuthRepositoryProtocol {
    func signIn() async throws -> GoogleOAuthPayload
}

// MARK: - Dependencies
public struct GoogleOAuthRepositoryDependencyKey: DependencyKey {
    public static var liveValue:  GoogleOAuthRepositoryProtocol {
        fatalError("GoogleOAuthServiceDependency liveValue not implemented")
    }
    public static var previewValue:  GoogleOAuthRepositoryProtocol = MockGoogleOAuthRepository()
    public static var testValue:  GoogleOAuthRepositoryProtocol = MockGoogleOAuthRepository()
}

public extension DependencyValues {
    var googleOAuthRepository:  GoogleOAuthRepositoryProtocol {
        get { self[GoogleOAuthRepositoryDependencyKey.self] }
        set { self[GoogleOAuthRepositoryDependencyKey.self] = newValue }
    }
}
