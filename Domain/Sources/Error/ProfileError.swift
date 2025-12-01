//
//  ProfileError.swift
//  Domain
//
//  Created by Wonji Suh on 01/14/26.
//

import Foundation

public enum ProfileError: Error, Equatable, LocalizedError {
  case notFound
  case unauthorized
  case network(String)
  case decoding
  case unknown(String)

  public var errorDescription: String? {
    switch self {
    case .notFound:
      return "프로필 정보를 찾을 수 없습니다."
    case .unauthorized:
      return "로그인이 필요합니다."
    case .network(let message):
      return "네트워크 오류가 발생했습니다: \(message)"
    case .decoding:
      return "프로필 데이터를 해석할 수 없습니다."
    case .unknown(let message):
      return "알 수 없는 오류가 발생했습니다: \(message)"
    }
  }
}
