//
//  OAuthCheckUserInput.swift
//  Domain
//
//  Created by Wonji Suh  on 11/21/25.
//

import Foundation

public struct OAuthUserInput {
    public let accessToken: String
    public let socialType: SocialType
    public let authorizationCode: String?
    public let codeVerifier: String?
    public let redirectUri: String?
    
    public init(
        accessToken: String,
        socialType: SocialType,
        authorizationCode: String?,
        codeVerifier: String? = nil,
        redirectUri: String? = nil
    ) {
        self.accessToken = accessToken
        self.socialType = socialType
        self.authorizationCode = authorizationCode
        self.codeVerifier = codeVerifier
        self.redirectUri = redirectUri
    }
}
