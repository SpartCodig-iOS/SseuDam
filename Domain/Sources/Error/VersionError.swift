//
//  VersionError.swift
//  Domain
//
//  Created by Wonji Suh on 12/9/25.
//

import Foundation

public enum VersionError: Error, Equatable, LocalizedError, Hashable {
  /// 네트워크 통신 실패
  case networkError(String)
  /// 서버 응답이 유효하지 않음
  case invalidResponse(String)
  /// 버전 정보 파싱 실패
  case parsingError(String)
  /// 지원하지 않는 플랫폼 혹은 번들 ID
  case unsupported
  /// 알 수 없는 오류
  case unknown(String)

  public var errorDescription: String? {
    switch self {
    case .networkError(let message):
      return "버전 정보를 불러오는 중 네트워크 오류가 발생했습니다: \(message)"
    case .invalidResponse(let message):
      return "서버 응답이 올바르지 않습니다: \(message)"
    case .parsingError(let message):
      return "버전 정보를 해석하지 못했습니다: \(message)"
    case .unsupported:
      return "현재 플랫폼이나 번들 ID는 지원되지 않습니다."
    case .unknown(let message):
      return "알 수 없는 오류가 발생했습니다: \(message)"
    }
  }
}

