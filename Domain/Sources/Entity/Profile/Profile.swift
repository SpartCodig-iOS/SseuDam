//
//  Profile.swift
//  Domain
//
//  Created by Wonji Suh  on 12/1/25.
//

import Foundation

public struct Profile: Equatable, Hashable {
    public let userId: String
    public let email: String
    public let name: String
    public let profileImage: String?
    public let provider: SocialType
    
    public init(
        userId: String,
        email: String,
        name: String,
        profileImage: String?,
        provider: SocialType
    ) {
        self.userId = userId
        self.email = email
        self.name = name
        self.profileImage = profileImage
        self.provider = provider
    }
}
