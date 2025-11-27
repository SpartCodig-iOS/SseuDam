//
//  OAuthCheckUser.swift
//  Domain
//
//  Created by Wonji Suh  on 11/21/25.
//

import Foundation

public struct OAuthCheckUser: Equatable {
    public var registered: Bool
    
    public init(
        registered: Bool
    ) {
        self.registered = registered
    }
}
