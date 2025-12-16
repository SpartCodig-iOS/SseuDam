//
//  LoginRepositoryProtocol.swift
//  Domain
//
//  Created by Wonji Suh  on 11/26/25.
//
import Foundation
import Dependencies

public protocol LoginRepositoryProtocol {
    func login(input: OAuthUserInput) async throws -> AuthResult
}

// MARK: - Dependencies
public struct LoginRepositoryDependency: DependencyKey {
    public static var liveValue: LoginRepositoryProtocol {
        fatalError("LoginRepositoryDependency liveValue not implemented")
    }
    public static var previewValue: LoginRepositoryProtocol = MockLoginRepository()
    public static var testValue: LoginRepositoryProtocol = MockLoginRepository()
}

public extension DependencyValues {
    var loginRepository: LoginRepositoryProtocol {
        get { self[LoginRepositoryDependency.self] }
        set { self[LoginRepositoryDependency.self] = newValue }
    }
}
