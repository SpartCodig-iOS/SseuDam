//
//  OAuthUseCaseError.swift
//  Domain
//
//  Created by Wonji Suh  on 11/17/25.
//

import Foundation

public enum OAuthUseCaseError: LocalizedError {
  case missingUser

  public var errorDescription: String? {
    switch self {
    case .missingUser:
      return "Supabase 세션에서 사용자 정보를 찾을 수 없습니다."
    }
  }
}

