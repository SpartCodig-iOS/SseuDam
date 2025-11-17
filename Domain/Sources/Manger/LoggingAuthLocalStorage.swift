//
//  LoggingAuthLocalStorage.swift
//  Domain
//
//  Created by Wonji Suh  on 11/17/25.
//

import Supabase
import LogMacro

final class LoggingAuthLocalStorage: AuthLocalStorage, @unchecked Sendable {
  private let base: any AuthLocalStorage

  init(base: any AuthLocalStorage = AuthClient.Configuration.defaultLocalStorage) {
    self.base = base
  }

  func store(key: String, value: Data) throws {
    logIfNeeded(action: "store", key: key, data: value)
    try base.store(key: key, value: value)
  }

  func retrieve(key: String) throws -> Data? {
    let data = try base.retrieve(key: key)
    logIfNeeded(action: "retrieve", key: key, data: data)
    return data
  }

  func remove(key: String) throws {
    if key.contains("code-verifier") {
      Log.info("PKCE codeVerifier removed for key \(key)")
    }
    try base.remove(key: key)
  }

  private func logIfNeeded(action: String, key: String, data: Data?) {
    guard
      key.contains("code-verifier"),
      let data,
      let code = String(data: data, encoding: .utf8)
    else { return }

    Log.info("PKCE codeVerifier \(action) for key \(key): \(code)")
  }
}
