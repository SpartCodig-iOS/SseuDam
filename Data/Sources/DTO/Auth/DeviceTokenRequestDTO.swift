//
//  DeviceTokenRequestDTO.swift
//  Data
//
//  Created by Wonji Suh  on 12/11/25.
//

import Foundation

public struct DeviceTokenRequestDTO: Encodable {
  let deviceToken: String
  let pendingKey: String
}
