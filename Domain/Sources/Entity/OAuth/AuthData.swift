//
//  OAuthData.swift
//  Domain
//
//  Created by Wonji Suh  on 11/27/25.
//

import Foundation

public struct AuthData: Hashable {
    let socialType: SocialType
    let accessToken: String
    let authToken: String
    let displayName: String?
    let authorizationCode: String?
    let codeVerifier: String?
    let redirectUri: String?
    let refreshToken: String?
    let sessionID: String?
    let userId: String?
}
