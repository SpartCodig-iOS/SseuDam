//
//  GoogleSignInError.swift
//  Domain
//
//  Created by Wonji Suh  on 11/17/25.
//

import Foundation

public enum GoogleSignInError: LocalizedError {
  case configurationMissing
  case missingPresentingController
  case missingIDToken
  case userCancelled

  public var errorDescription: String? {
    switch self {
      case .configurationMissing:
        return "Google Client ID가 설정되지 않았습니다."
      case .missingPresentingController:
        return "프레젠트할 뷰 컨트롤러를 찾을 수 없습니다."
      case .missingIDToken:
        return "Google ID 토큰을 가져오지 못했습니다."
      case .userCancelled:
        return "사용자가 Google 로그인을 취소했습니다."
    }
  }
}
