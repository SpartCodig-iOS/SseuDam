//
//  SessionMapper.swift
//  Data
//
//  Created by Wonji Suh  on 11/25/25.
//

import Foundation
import Domain

public extension SessionResponseDTO {
  func toDomain() -> SessionStatus {
    let socialType = SocialType(rawValue: self.loginType) ?? .none
    return SessionStatus(
      provider: socialType,
      sessionId: self.sessionID,
      status: self.status
    )
  }
}
