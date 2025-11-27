//
//  SignUpUseCaseProtocol.swift
//  Domain
//
//  Created by Wonji Suh  on 11/26/25.
//

import Foundation

public protocol SignUpUseCaseProtocol {
    func checkUserSignUp(accessToken: String, socialType: SocialType) async throws -> OAuthCheckUser
    func signUp(accessToken: String, socialType: SocialType, authCode: String) async throws -> AuthResult
}
