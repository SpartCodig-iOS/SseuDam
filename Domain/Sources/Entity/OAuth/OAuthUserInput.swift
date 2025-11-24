//
//  OAuthCheckUserInput.swift
//  Domain
//
//  Created by Wonji Suh  on 11/21/25.
//

public struct OAuthUserInput {
  public let accessToken: String
  public let socialType: SocialType

  public init(accessToken: String, socialType: SocialType) {
    self.accessToken = accessToken
    self.socialType = socialType
  }
}
