//
//  Extension+MoyaProvider+Auth.swift
//  Data
//
//  Created by Wonji Suh on 01/14/26.
//

import Moya
import NetworkService

public extension MoyaProvider {
  static var authorized: MoyaProvider {
    MoyaProvider(
      session: AuthSessionManager.shared.session,
      plugins: [
        MoyaLoggingPlugin()
      ]
    )
  }
}
