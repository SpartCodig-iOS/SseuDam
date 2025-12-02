//
//  ProfileEditPayload.swift
//  Domain
//
//  Created by Wonji Suh on 01/14/26.
//

import Foundation

public struct ProfileEditPayload: Equatable {
  public let name: String?
  public let avatarData: Data?
  public let fileName: String?

  public init(
    name: String? = nil,
    avatarData: Data? = nil,
    fileName: String? = nil
  ) {
    self.name = name
    self.avatarData = avatarData
    self.fileName = fileName
  }
}
