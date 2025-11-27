//
//  SignUpRepositoryProtocol.swift
//  Domain
//
//  Created by Wonji Suh  on 11/26/25.
//

import Foundation

public protocol SignUpRepositoryProtocol {
    func checkSignUp(input: OAuthUserInput) async throws -> OAuthCheckUser
    func signUp(input: OAuthUserInput) async throws -> AuthResult
  
}

