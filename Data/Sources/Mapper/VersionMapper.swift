//
//  VersionMapper.swift
//  Data
//
//  Created by Wonji Suh  on 12/8/25.
//

import Foundation
import Domain

extension VersionResponseDTO {
  func toDomain() -> Version {
    return Version(
      message: self.message,
      shouldUpdate: self.shouldUpdate,
      appStoreUrl: self.appStoreURL,
      version: self.latestVersion
    )
  }
}
