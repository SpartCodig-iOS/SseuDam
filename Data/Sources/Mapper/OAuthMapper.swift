//
//  OAuthMapper.swift
//  Data
//
//  Created by Wonji Suh  on 11/21/25.
//

import Domain


extension OAuthCheckUserResponseDTO {
  func toDomain() -> OAuthCheckUser {
    return OAuthCheckUser(
      registered: self.registered
    )
  }
}
