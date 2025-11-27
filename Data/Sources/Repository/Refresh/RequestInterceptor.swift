//
//  RequestInterceptor.swift
//  Data
//
//  Created by Wonji Suh  on 11/28/25.
//

import Foundation
import Domain
import Alamofire
import LogMacro
import NetworkService


public final actor RequestInterceptorManger {
  public static let shared = RequestInterceptorManger()
  private let repository = AuthRepository()

  public func refreshToken() async -> RetryResult {
    let token = KeychainManager.shared.loadRefreshToken() ?? ""
    do {
      let tokenResult = try await repository.refresh(token: token)

      // 새로운 토큰들을 keychain에 저장
      KeychainManager.shared.saveTokens(
        accessToken: tokenResult.token.accessToken,
        refreshToken: tokenResult.token.refreshToken
      )

      Log.info("토큰 갱신 성공")
      return .retry

    } catch {
      Log.error("토큰 갱신 실패", error.localizedDescription)
      return .doNotRetryWithError(error)
    }
  }
}
