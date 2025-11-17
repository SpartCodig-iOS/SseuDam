//
//  GoogleAuthManager.swift
//  Data
//
//  Created by Wonji Suh  on 11/17/25.
//

import Combine
import LogMacro

@MainActor
@Observable
final class GoogleAuthManager {
  static let shared = GoogleAuthManager()

  var isSigningIn: Bool = false
  var displayName: String?
  var lastError: Error?

  private let googleService: GoogleOAuthServicing

  init(googleService: GoogleOAuthServicing = GoogleOAuthService()) {
    self.googleService = googleService
  }

  func signIn() async {
    guard !isSigningIn else { return }

    isSigningIn = true
    lastError = nil

    do {
      // 1) Google 로그인
      let payload = try await googleService.signIn()
      displayName = payload.displayName
      Log.info("Google sign-in succeeded for \(payload.displayName ?? "unknown user")")

      // 2) Supabase 로그인
      if let client = SuperBaseManger.shared.client {
        let credentials = payload.toSupabaseGoogleCredentials()

        do {
          try await client.auth.signInWithIdToken(
            credentials: credentials
          )
          Log.info("Supabase sign-in with Google succeeded")
        } catch {
          Log.info("Supabase sign-in with Google failed: \(error.localizedDescription)")
          lastError = error
        }
      } else {
        Log.info("Supabase client is not configured; skipping Supabase sign-in")
      }

    } catch {
      if let signInError = error as? GoogleSignInError, signInError == .userCancelled {
        Log.info("Google sign-in cancelled by user.")
      } else {
        Log.info("Google sign-in failed: \(error.localizedDescription)")
        lastError = error
      }
    }

    isSigningIn = false
  }

  func resetError() {
    lastError = nil
  }
}
