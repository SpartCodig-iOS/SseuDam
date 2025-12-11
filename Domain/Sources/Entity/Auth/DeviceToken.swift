//
//  DeviceToken.swift
//  Domain
//
//  Created by Wonji Suh  on 12/11/25.
//

import Foundation

public struct DeviceToken {
    public let deviceToken: String
    public let pendingKey: String?
    
    public init(
        deviceToken: String,
        pendingKey: String?
    ) {
        self.deviceToken = deviceToken
        self.pendingKey = pendingKey
    }
    
}
