//
//  OAuthMapper.swift
//  Data
//
//  Created by Wonji Suh  on 11/21/25.
//

import Domain


extension OAuthCheckUserResponseDTO {
    func toDomain() -> OAuthCheckUser {
        return OAuthCheckUser(
            registered: self.registered
        )
    }
}

extension OAuthResponseDTO {
    func toDomain() -> AuthEntity {
        let token = AuthTokens(
            authToken: "",
            accessToken: self.accessToken,
            refreshToken: self.refreshToken,
            sessionID: self.sessionID
        )
        let socialtype = SocialType(rawValue: self.loginType)
        return AuthEntity(
            name: self.user.name,
            provider: socialtype ?? .none,
            token: token
        )
    }
}
