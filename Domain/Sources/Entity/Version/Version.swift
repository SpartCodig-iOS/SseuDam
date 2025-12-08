//
//  Version.swift
//  Domain
//
//  Created by Wonji Suh  on 12/8/25.
//

import Foundation

public struct Version: Equatable {
    public let message: String
    public let shouldUpdate: Bool
    public let appStoreUrl: String
    public let version: String

    public init(
        message: String,
        shouldUpdate: Bool,
        appStoreUrl: String,
        version: String
    ) {
        self.message = message
        self.shouldUpdate = shouldUpdate
        self.appStoreUrl = appStoreUrl
        self.version = version
    }
}
