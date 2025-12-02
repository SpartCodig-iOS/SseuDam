//
//  AuthDeleteStatus.swift
//  Domain
//
//  Created by Wonji Suh  on 12/2/25.
//

import Foundation

public struct AuthDeleteStatus: Equatable {
  public let isDeleted: Bool

  public init(isDeleted: Bool) {
    self.isDeleted = isDeleted
  }
}
