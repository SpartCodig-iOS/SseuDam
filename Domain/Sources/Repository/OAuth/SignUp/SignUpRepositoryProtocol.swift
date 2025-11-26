//
//  SignUpRepositoryProtocol.swift
//  Domain
//
//  Created by Wonji Suh  on 11/26/25.
//

import Foundation

public protocol SignUpRepositoryProtocol {
    func checkSignUpUser(input: OAuthCheckUserInput) async throws -> OAuthCheckUser
}

