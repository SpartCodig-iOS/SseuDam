//
//  AuthMapper.swift
//  Data
//
//  Created by Wonji Suh  on 11/27/25.
//

import Foundation
import Domain

public extension RefreshResponseDTO {
  func toDomain() -> TokenResult {
    let token  = AuthTokens(
      authToken: "",
      accessToken: self.accessToken,
      refreshToken: self.refreshToken,
      sessionID: self.sessionID
    )

    return TokenResult(token: token)
  }
}


public extension LogoutResponseDTO {
  func toDomain() -> LogoutStatus {
    return LogoutStatus(revoked: self.revoked)
  }
}


public extension AuthDeleteResponseDTO {
  func toDomain() -> AuthDeleteStatus {
    return AuthDeleteStatus(isDeleted: self.supabaseDeleted)
  }
}

public extension DeviceTokenResponseDTO {
  func toDomain() -> DeviceToken {
    return DeviceToken(
      deviceToken: self.deviceToken,
      pendingKey: self.pendingKey
    )
  }
}
