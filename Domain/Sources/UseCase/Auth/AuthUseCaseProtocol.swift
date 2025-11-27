//
//  AuthUseCaseProtocol.swift
//  Domain
//
//  Created by Wonji Suh  on 11/27/25.
//

import Foundation

public protocol AuthUseCaseProtocol {
  func refresh() async throws  -> TokenResult
}
