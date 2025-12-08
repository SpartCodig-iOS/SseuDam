//
//  VersionRequestDTO.swift
//  Data
//
//  Created by Wonji Suh  on 12/8/25.
//

import Foundation

public struct VersionRequestDTO: Encodable {
  let bundleId: String
  let currentVersion: String
}
