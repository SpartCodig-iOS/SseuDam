//
//  LogoutStatus.swift
//  Domain
//
//  Created by Wonji Suh  on 12/1/25.
//

import Foundation

public struct LogoutStatus: Equatable, Hashable {
    public let revoked: Bool
    
    public init(
        revoked: Bool
    ) {
        self.revoked = revoked
    }
}
