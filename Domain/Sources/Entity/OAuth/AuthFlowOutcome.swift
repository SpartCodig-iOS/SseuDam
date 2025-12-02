//
//  AuthFlowOutcome.swift
//  Domain
//
//  Created by Wonji Suh on 12/02/25.
//

import Foundation

/// OAuth 인증 플로우의 결과를 나타내는 enum
public enum AuthFlowOutcome: Equatable, Hashable {
    /// 로그인 성공 (기존 사용자)
    case loginSuccess(AuthResult)
    /// 회원가입 성공 (신규 사용자)
    case signUpSuccess(AuthResult)
    /// 약관 동의 필요 (OAuth 데이터 포함)
    case needsTermsAgreement(AuthData)
    /// 인증 실패
    case failure(AuthError)
}