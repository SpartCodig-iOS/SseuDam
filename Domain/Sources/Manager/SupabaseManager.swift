//
//  SupabaseManager.swift
//  Domain
//
//  Created by Wonji Suh  on 11/17/25.
//

import Foundation
import Supabase
import LogMacro

public final class SupabaseManager {
  public static let shared = SupabaseManager()

  public let client: SupabaseClient
  private let authStorage = LoggingAuthLocalStorage()

  private init() {
    self.client = SupabaseManager.makeClient(authStorage: authStorage)
  }

  private static func makeClient(authStorage: AuthLocalStorage) -> SupabaseClient {
    let urlString = "https://\(Bundle.main.object(forInfoDictionaryKey: "SUPERBASE_URL") as? String ?? "")"
    let anonKey = "\(Bundle.main.object(forInfoDictionaryKey: "SUPERBASE_KEY") as? String ?? "")"

    guard
      let supabaseURL = URL(string: urlString),
      !anonKey.isEmpty,
      anonKey != "YOUR_SUPABASE_ANON_KEY",
      !urlString.contains("YOUR-PROJECT")
    else {
      // 설정이 잘못된 경우 더미 URL 사용
      let dummyURL = URL(string: "https://dummy.supabase.co")!
      Log.error("Supabase configuration is missing or invalid. Using dummy client.")
      return SupabaseClient(supabaseURL: dummyURL, supabaseKey: "dummy-key")
    }

    let storageKey = Bundle.main.bundleIdentifier ?? "co.suhwonji.test"

    return SupabaseClient(
      supabaseURL: supabaseURL,
      supabaseKey: anonKey,
      options: .init(
        auth: .init(
          storage: authStorage,
          redirectToURL: URL(string: "sseudam://login-callback/"),
          storageKey: storageKey,
          flowType: .pkce,
          autoRefreshToken: true,
          emitLocalSessionAsInitialSession: true
        )
      )
    )
  }
}
