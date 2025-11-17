//
//  GoogleOAuthPayload.swift
//  Data
//
//  Created by Wonji Suh  on 11/17/25.
//

import Foundation
import Supabase

struct GoogleOAuthPayload {
  let idToken: String
  let accessToken: String?
  let authorizationCode: String?
  let displayName: String?
}


extension GoogleOAuthPayload {
  func toSupabaseGoogleCredentials() -> OpenIDConnectCredentials {
    .init(
      provider: .google,
      idToken: idToken,
      accessToken: accessToken
    )
  }
}
