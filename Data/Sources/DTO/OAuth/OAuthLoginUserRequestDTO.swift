//
//  OAuthLoginUserRequestDTO.swift
//  Data
//
//  Created by Wonji Suh  on 11/21/25.
//

import Foundation
import Domain

public struct LoginUserRequestDTO: Encodable {
    let accessToken: String
    let loginType: String
}
