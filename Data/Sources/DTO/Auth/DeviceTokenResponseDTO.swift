//
//  DeviceTokenResponseDTO.swift
//  Data
//
//  Created by Wonji Suh  on 12/11/25.
//

import Foundation

public struct DeviceTokenResponseDTO: Decodable {
    let deviceToken: String
    let pendingKey: String?
    let mode: String
}
