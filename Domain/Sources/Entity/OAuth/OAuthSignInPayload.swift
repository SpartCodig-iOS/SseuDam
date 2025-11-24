//
//  OAuthSignInPayload.swift
//  Domain
//
//  Created by Wonji Suh on 11/17/25.
//

import Foundation

public struct OAuthSignInPayload {
  public let provider: SocialType
  public let idToken: String
  public let nonce: String?
  public let displayName: String?
  public let authorizationCode: String?

  public init(
    provider: SocialType,
    idToken: String,
    nonce: String?,
    displayName: String?,
    authorizationCode: String?
  ) {
    self.provider = provider
    self.idToken = idToken
    self.nonce = nonce
    self.displayName = displayName
    self.authorizationCode = authorizationCode
  }
}
