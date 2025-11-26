//
//  GoogleOAuthServicing.swift
//  Domain
//
//  Created by Wonji Suh  on 11/17/25.
//

import Foundation
import Dependencies

public protocol GoogleOAuthRepositoryProtocol {
  func signIn() async throws -> GoogleOAuthPayload
}

