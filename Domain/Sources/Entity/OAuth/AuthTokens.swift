//
//  AuthTokens.swift
//  Domain
//
//  Created by Wonji Suh  on 11/17/25.
//


import Foundation

public struct AuthTokens: Equatable {
  public let superBaseToken: String
  public let accessToken: String
  public let refreshToken: String?

  public init(
    superBaseToken: String,
    accessToken: String,
    refreshToken: String?
  ) {
    self.superBaseToken = superBaseToken
    self.accessToken = accessToken
    self.refreshToken = refreshToken
  }
}
