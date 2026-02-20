//
//  Extension+MoyaProvider+Auth.swift
//  Data
//
//  Created by Wonji Suh  on 02/20/26.
//

import Moya
import NetworkService

public extension MoyaProvider {
  /// 인증이 필요한 API 호출을 위한 Provider
  static var authorized: MoyaProvider<Target> {
    let manager = AuthSessionManager.shared

    return MoyaProvider(
      session: manager.session,
      plugins: [
        MoyaLoggingPlugin()
      ]
    )
  }

  /// 인증이 필요하지 않은 API 호출을 위한 Provider (토큰 갱신 등)
  static var `default`: MoyaProvider<Target> {
    return MoyaProvider(
      plugins: [
        MoyaLoggingPlugin()
      ]
    )
  }
}