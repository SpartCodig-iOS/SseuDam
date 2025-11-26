//
//  SignUpRepositoryProtocol.swift
//  Domain
//
//  Created by Wonji Suh  on 11/26/25.
//

import Foundation

public protocol SignUpRepositoryProtocol {
    func checkSignUpUser(input: OAuthUserInput) async throws -> OAuthCheckUser
    func signUpUser(input: OAuthUserInput) async throws -> AuthEntity
  
}

