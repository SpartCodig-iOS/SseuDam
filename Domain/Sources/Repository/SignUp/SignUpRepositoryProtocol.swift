//
//  SignUpRepositoryProtocol.swift
//  Domain
//
//  Created by Wonji Suh  on 11/26/25.
//

import Foundation
import Dependencies

public protocol SignUpRepositoryProtocol {
    func checkSignUp(input: OAuthUserInput) async throws -> OAuthCheckUser
    func signUp(input: OAuthUserInput) async throws -> AuthResult
  
}

// MARK: - Dependencies
public struct SignUpRepositoryDependency: DependencyKey {
    public static var liveValue: SignUpRepositoryProtocol {
        fatalError("SignUpRepositoryDependency liveValue not implemented")
    }
    public static var previewValue: SignUpRepositoryProtocol = MockSignUpRepository()
    public static var testValue: SignUpRepositoryProtocol = MockSignUpRepository()
}

public extension DependencyValues {
    var signUpRepository: SignUpRepositoryProtocol {
        get { self[SignUpRepositoryDependency.self] }
        set { self[SignUpRepositoryDependency.self] = newValue }
    }
}
