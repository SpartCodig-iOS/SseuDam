//
//  OAuthSignUpUserRequestDTO.swift
//  Data
//
//  Created by Wonji Suh  on 11/25/25.
//

public struct OAuthSignUpUserRequestDTO: Encodable {
  let accessToken: String
  let loginType: String
  let authorizationCode: String
}
