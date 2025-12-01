//
//  Profile.swift
//  Domain
//
//  Created by Wonji Suh  on 12/1/25.
//

import Foundation

public struct Profile: Equatable {
    public let userId: String
    public let email: String
    public let name: String
    public let provider: SocialType

  public init(
    userId: String,
    email: String,
    name: String,
    provider: SocialType
  ) {
    self.userId = userId
    self.email = email
    self.name = name
    self.provider = provider
  }
}
