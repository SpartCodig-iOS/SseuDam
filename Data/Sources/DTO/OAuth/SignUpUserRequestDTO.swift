//
//  OAuthSignUpUserRequestDTO.swift
//  Data
//
//  Created by Wonji Suh  on 11/25/25.
//

public struct SignUpUserRequestDTO: Encodable {
    let accessToken: String
    let loginType: String
    let authorizationCode: String?
    let codeVerifier: String?
    let redirectUri: String?
}
