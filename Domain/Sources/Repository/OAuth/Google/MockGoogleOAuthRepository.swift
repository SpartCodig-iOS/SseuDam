//
//  MockGoogleOAuthRepository.swift
//  Domain
//
//  Created by Wonji Suh  on 11/18/25.
//

import Foundation

public struct MockGoogleOAuthRepository: GoogleOAuthProtocol {

  public init() {}

  public func signIn() async throws -> GoogleOAuthPayload {
    return GoogleOAuthPayload(
      idToken: "mock-google-id-token",
      accessToken: "mock-google-access-token",
      authorizationCode: "mock-google-auth-code",
      displayName: "Mock Google User"
    )
  }
}
