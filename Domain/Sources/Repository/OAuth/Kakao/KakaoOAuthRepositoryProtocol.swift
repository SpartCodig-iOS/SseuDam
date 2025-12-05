//
//  KakaoOAuthRepositoryProtocol.swift
//  Domain
//
//  Created by Assistant on 12/4/25.
//

import Foundation
import Dependencies

public protocol KakaoOAuthRepositoryProtocol {
  func signIn() async throws -> KakaoOAuthPayload
}
