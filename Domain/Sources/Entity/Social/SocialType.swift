//
//  SocialType.swift
//  Domain
//
//  Created by Wonji Suh  on 11/17/25.
//

import Foundation
import Supabase


public enum SocialType: String, CaseIterable, Identifiable, Hashable {
  case none
  case apple
  case google

  public var id: String { rawValue }

  var description: String {
    switch self {
      case .none:
        return "email"
      case .apple:
        return "Apple"
      case .google:
        return "Google"

    }
  }


  public var image: String {
    switch self {
      case .apple:
        return "apple.logo"
      case .google:
        return "google"
      case .none:
        return ""
    }
  }

  public var supabaseProvider: Auth.Provider {
    switch self {
      case .google: return .google
      case .apple: return .apple
      case .none: return .email
    }
  }
}
