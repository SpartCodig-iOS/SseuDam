//
//  VersionUseCaseProtocol.swift
//  Domain
//
//  Created by Wonji Suh  on 12/8/25.
//

import Foundation

public protocol VersionUseCaseProtocol {
  func getVersion(bundleId: String, version: String) async throws -> Version
}
