//
//  SupabaseGoogleCredentials.swift
//  Data
//
//  Created by Wonji Suh  on 11/17/25.
//

import Supabase

struct SupabaseGoogleCredentials {
  let provider: Provider
  let idToken: String
  let accessToken: String?

  init(idToken: String, accessToken: String?) {
    self.provider = .google
    self.idToken = idToken
    self.accessToken = accessToken
  }

  func toSupabaseCredentials() -> OpenIDConnectCredentials.Provider {
    .init(
      provider: provider,
      idToken: idToken,
      accessToken: accessToken
    )
  }
}
