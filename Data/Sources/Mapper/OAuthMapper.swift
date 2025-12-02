//
//  OAuthMapper.swift
//  Data
//
//  Created by Wonji Suh  on 11/21/25.
//

import Domain


extension ChecSignUpResponseDTO {
    func toDomain() -> OAuthCheckUser {
        return OAuthCheckUser(
            registered: self.registered,
            needsTerms: !self.registered  // 미등록 사용자는 항상 약관 동의 필요
        )
    }
}

extension AuthResponseDTO {
    func toDomain() -> AuthResult {
        let token = AuthTokens(
            authToken: "",
            accessToken: self.accessToken,
            refreshToken: self.refreshToken,
            sessionID: self.sessionID
        )
        let socialtype = SocialType(rawValue: self.loginType ?? "")
        return AuthResult(
          userId: self.user.id,
          name: self.user.name,
            provider: socialtype ?? .none,
            token: token
        )
    }
}
