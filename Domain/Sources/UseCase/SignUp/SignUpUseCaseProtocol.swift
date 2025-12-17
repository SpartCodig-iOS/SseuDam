//
//  SignUpUseCaseProtocol.swift
//  Domain
//
//  Created by Wonji Suh  on 12/17/25.
//

import Foundation

public protocol SignUpUseCaseProtocol {
    func checkUser(_ authData: AuthData) async -> Result<OAuthCheckUser, AuthError>
    func signUp(_ authData: AuthData) async -> Result<AuthResult, AuthError>
    func finalizeKakao(ticket: String) async -> Result<AuthResult, AuthError>
}
