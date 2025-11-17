//
//  GoogleOAuthService.swift
//  Data
//
//  Created by Wonji Suh  on 11/17/25.
//

import Foundation
import GoogleSignIn
import Supabase
import LogMacro
import Domain

#if canImport(UIKit)
import UIKit
#endif

public final class GoogleOAuthService: GoogleOAuthServicing {
  private let configuration: GoogleOAuthConfiguration

  public init(configuration: GoogleOAuthConfiguration = .current) {
    self.configuration = configuration
  }

  @MainActor
  public func signIn() async throws -> GoogleOAuthPayload {
    guard configuration.isValid else {
      throw GoogleSignInError.configurationMissing
    }

#if canImport(UIKit)
    guard let presenting = Self.topViewController() else {
      throw GoogleSignInError.missingPresentingController
    }
#else
    throw GoogleSignInError.missingPresentingController
#endif

    let gidConfiguration = GIDConfiguration(
      clientID: configuration.clientID,
      serverClientID: configuration.serverClientID
    )
    GIDSignIn.sharedInstance.configuration = gidConfiguration

    return try await withCheckedThrowingContinuation { continuation in
      Task { @MainActor in
        do {
          let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: presenting)
          guard let idToken = result.user.idToken?.tokenString else {
            continuation.resume(throwing: GoogleSignInError.missingIDToken)
            return
          }

          let payload = GoogleOAuthPayload(
            idToken: idToken,
            accessToken: "",
            authorizationCode: result.serverAuthCode,
            displayName: result.user.profile?.name
          )

          Log.info("Google serverAuthCode present: \(payload.authorizationCode != nil ? "yes" : "no")")
          continuation.resume(returning: payload)
        } catch let error as NSError {
          if error.domain == "RBSServiceErrorDomain" && error.code == 1 {
            Log.error("RBSServiceErrorDomain detected, retrying Google sign-in...")
            // RBSServiceErrorDomain 에러 발생 시 재시도
            do {
              try await Task.sleep(for: .seconds(0.5)) // 0.5초 대기
              let retryResult = try await GIDSignIn.sharedInstance.signIn(withPresenting: presenting)
              guard let idToken = retryResult.user.idToken?.tokenString else {
                continuation.resume(throwing: GoogleSignInError.missingIDToken)
                return
              }

              let payload = GoogleOAuthPayload(
                idToken: idToken,
                accessToken: "",
                authorizationCode: retryResult.serverAuthCode,
                displayName: retryResult.user.profile?.name
              )

              Log.info("Google sign-in retry succeeded")
              continuation.resume(returning: payload)
            } catch {
              Log.error("Google sign-in retry failed: \(error.localizedDescription)")
              continuation.resume(throwing: error)
            }
          } else if error.domain == "com.google.GIDSignIn",
                    error.code == GIDSignInError.canceled.rawValue {
            Log.info("Google sign-in cancelled by user.")
            continuation.resume(throwing: GoogleSignInError.userCancelled)
          } else {
            Log.error("Google sign-in failed: \(error.localizedDescription)")
            continuation.resume(throwing: error)
          }
        }
      }
    }
  }

#if canImport(UIKit)
  private static func topViewController(
    base: UIViewController? = UIApplication.shared.connectedScenes
      .compactMap { ($0 as? UIWindowScene)?.keyWindow }
      .first?.rootViewController
  ) -> UIViewController? {
    if let nav = base as? UINavigationController {
      return topViewController(base: nav.visibleViewController)
    }
    if let tab = base as? UITabBarController, let selected = tab.selectedViewController {
      return topViewController(base: selected)
    }
    if let presented = base?.presentedViewController {
      return topViewController(base: presented)
    }
    return base
  }
#endif
}
