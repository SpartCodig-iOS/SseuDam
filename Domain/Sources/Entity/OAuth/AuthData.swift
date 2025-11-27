//
//  OAuthData.swift
//  Domain
//
//  Created by Wonji Suh  on 11/27/25.
//

import Foundation

public struct AuthData {
    let socialType: SocialType
    let accessToken: String
    let idToken: String
    let displayName: String?
    let authorizationCode: String
}
