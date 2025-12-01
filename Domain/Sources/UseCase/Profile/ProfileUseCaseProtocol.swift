//
//  ProfileUseCaseProtocol.swift
//  Domain
//
//  Created by Wonji Suh  on 12/1/25.
//

import Foundation

public protocol ProfileUseCaseProtocol {
  func getProfile() async throws -> Profile
}
