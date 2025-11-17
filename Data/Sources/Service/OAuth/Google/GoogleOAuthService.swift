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

#if canImport(UIKit)
import UIKit
#endif

protocol GoogleOAuthServicing {
  func signIn() async throws -> GoogleOAuthPayload
}


final class GoogleOAuthService: GoogleOAuthServicing {
  private let configuration: GoogleOAuthConfiguration

  init(configuration: GoogleOAuthConfiguration = .current) {
    self.configuration = configuration
  }

  func signIn() async throws -> GoogleOAuthPayload {
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

    do {
      let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: presenting)
      guard let idToken = result.user.idToken?.tokenString else {
        throw GoogleSignInError.missingIDToken
      }

      let payload = GoogleOAuthPayload(
        idToken: idToken,
        authorizationCode: result.serverAuthCode,
        displayName: result.user.profile?.name
      )

      Log.info("Google serverAuthCode present: \(payload.authorizationCode != nil ? "yes" : "no")")
      return payload
    } catch let error as NSError {
      if error.domain == "com.google.GIDSignIn",
         error.code == GIDSignInError.canceled.rawValue {
        Log.info("Google sign-in cancelled by user.")
        throw GoogleSignInError.userCancelled
      }
      Log.error("Google sign-in failed: \(error.localizedDescription)")
      throw error
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
