//
//  UserEntity.swift
//  Domain
//
//  Created by Wonji Suh  on 11/17/25.
//

import Supabase

public struct UserEntity: Equatable, Identifiable {

  public let id: String
  public let email: String?
  public let displayName: String?
  public let provider: SocialType
  public let tokens: AuthTokens
  public let authCode: String?

  public init(
    id: String = "",
    email: String? = nil,
    displayName: String? = nil,
    provider: SocialType = .none,
    tokens: AuthTokens = AuthTokens(superBaseToken: "", accessToken: "", refreshToken: ""),
    authCode: String? = nil
  ) {
    self.id = id
    self.email = email
    self.displayName = displayName
    self.provider = provider
    self.tokens = tokens
    self.authCode = authCode
  }
}


extension AnyJSON {
  var stringValue: String? {
    if case let .string(value) = self {
      return value
    }
    return nil
  }

  var arrayValue: [AnyJSON]? {
    if case let .array(value) = self {
      return value
    }
    return nil
  }
}

public extension User {
  private var providerString: String? {
    if let provider = appMetadata["provider"]?.stringValue {
      return provider
    }

    if let providers = appMetadata["providers"]?.arrayValue,
       let first = providers.first?.stringValue {
      return first
    }
    return nil
  }

  private var displayNameValue: String? {
    if let name = userMetadata["display_name"]?.stringValue, !name.isEmpty {
      return name
    }
    if let name = userMetadata["full_name"]?.stringValue, !name.isEmpty {
      return name
    }
    if let name = userMetadata["name"]?.stringValue, !name.isEmpty {
      return name
    }
    return nil
  }

  func toDomain(session: Session, authCode: String?) -> UserEntity {
    .init(
      id: id.uuidString,
      email: email,
      displayName: displayNameValue,
      provider: SocialType(rawValue: providerString ?? "") ?? .none,
      tokens: .init(
        superBaseToken: session.accessToken,
        accessToken: "",
        refreshToken: ""
      ),
      authCode: authCode
    )
  }
}
