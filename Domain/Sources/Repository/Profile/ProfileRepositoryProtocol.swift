//
//  ProfileRepositoryProtocol.swift
//  Domain
//
//  Created by Wonji Suh  on 12/1/25.
//

import Foundation

public protocol ProfileRepositoryProtocol {
  func getProfile() async throws -> Profile
}
