//
//  LoginRepositoryProtocol.swift
//  Domain
//
//  Created by Wonji Suh  on 11/26/25.
//

public protocol LoginRepositoryProtocol {
  func loginUser(input: OAuthUserInput) async throws -> AuthEntity
}
