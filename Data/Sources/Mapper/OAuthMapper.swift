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
        // 새 포맷(tokenPair/session) 우선 사용, 없으면 구 포맷 fallback
        let access = tokenPair?.accessToken ?? accessToken ?? ""
        let refresh = tokenPair?.refreshToken ?? refreshToken ?? ""
        let sessionId = session?.sessionId ?? sessionID ?? ""

        let token = AuthTokens(
            authToken: access,
            accessToken: access,
            refreshToken: refresh,
            sessionID: sessionId
        )
        let socialtype = SocialType(rawValue: self.loginType ?? "")
        return AuthResult(
          userId: self.user.id,
          name: self.user.name ?? self.user.username ?? "" ,
            provider: socialtype ?? .none,
            token: token
        )
    }
}
