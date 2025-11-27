//
//  LoginUseCaseProtocol.swift
//  Domain
//
//  Created by Wonji Suh  on 11/26/25.
//

import Foundation

public protocol LoginUseCaseProtocol {
  func login(accessToken: String, socialType: SocialType) async throws -> AuthResult
}
