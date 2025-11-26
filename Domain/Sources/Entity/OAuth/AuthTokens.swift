//
//  AuthTokens.swift
//  Domain
//
//  Created by Wonji Suh  on 11/17/25.
//


import Foundation

public struct AuthTokens: Equatable {
  public let authToken: String
  public let accessToken: String
  public let refreshToken: String?

  public init(
    authToken: String,
    accessToken: String,
    refreshToken: String?
  ) {
    self.authToken = authToken
    self.accessToken = accessToken
    self.refreshToken = refreshToken
  }
}

