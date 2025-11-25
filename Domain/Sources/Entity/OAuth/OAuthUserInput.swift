//
//  OAuthCheckUserInput.swift
//  Domain
//
//  Created by Wonji Suh  on 11/21/25.
//

public struct OAuthUserInput {
  public let accessToken: String
  public let socialType: SocialType
  public let authorizationCode: String

  public init(
    accessToken: String,
    socialType: SocialType,
    authorizationCode: String
  ) {
    self.accessToken = accessToken
    self.socialType = socialType
    self.authorizationCode = authorizationCode
  }
}
