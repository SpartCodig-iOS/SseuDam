//
//  GoogleOAuthServicing.swift
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
public struct GoogleOAuthRespositoryDependency: DependencyKey {
    public static var liveValue:  GoogleOAuthRepositoryProtocol {
        fatalError("GoogleOAuthServiceDependency liveValue not implemented")
    }
    public static var previewValue:  GoogleOAuthRepositoryProtocol = MockGoogleOAuthRepository()
    public static var testValue:  GoogleOAuthRepositoryProtocol = MockGoogleOAuthRepository()
}

public extension DependencyValues {
    var googleOAuthService:  GoogleOAuthRepositoryProtocol {
        get { self[GoogleOAuthRespositoryDependency.self] }
        set { self[GoogleOAuthRespositoryDependency.self] = newValue }
    }
}
