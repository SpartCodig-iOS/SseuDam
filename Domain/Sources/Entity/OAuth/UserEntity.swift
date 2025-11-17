//
//  UserEntity.swift
//  Domain
//
//  Created by Wonji Suh  on 11/17/25.
//

public struct UserEntity: Equatable, Identifiable {

  public let id: String
  public var userId: String
  public let email: String?
  public let displayName: String?
  public let provider: SocialType
  public let tokens: AuthTokens

  public init(
    id: String = "",
    userId: String = "",
    email: String? = nil,
    displayName: String? = nil,
    provider: SocialType = .none,
    tokens: AuthTokens = AuthTokens(superBaseToken: "", accessToken: "", refreshToken: "")
  ) {
    self.id = id
    self.email = email
    self.displayName = displayName
    self.provider = provider
    self.tokens = tokens
    self.userId = userId
  }
}
