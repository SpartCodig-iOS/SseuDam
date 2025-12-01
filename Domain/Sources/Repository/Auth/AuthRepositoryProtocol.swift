//
//  AuthRepositoryProtocol.swift
//  Domain
//
//  Created by Wonji Suh  on 11/27/25.
//

import Foundation

public protocol AuthRepositoryProtocol {
  func refresh(token: String) async throws -> TokenResult
}
