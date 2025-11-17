//
//  AppleOAuthRepository.swift
//  Data
//
//  Created by Wonji Suh  on 11/17/25.
//

import Foundation
import AuthenticationServices
import CryptoKit
import LogMacro
import Domain

#if canImport(UIKit)
import UIKit
#endif

public final class AppleOAuthRepository: NSObject, AppleOAuthProtocol {
  private let logger = LogMacro.Log.self
  private var currentNonce: String?
  private var signInContinuation: CheckedContinuation<AppleOAuthPayload, Error>?

  public override init() {
    super.init()
  }

  @MainActor
  public func signIn() async throws -> AppleOAuthPayload {
    return try await withCheckedThrowingContinuation { continuation in
      self.signInContinuation = continuation

      let nonce = randomNonceString()
      self.currentNonce = nonce

      let request = ASAuthorizationAppleIDProvider().createRequest()
      request.requestedScopes = [.fullName, .email]
      request.nonce = sha256(nonce)

      let controller = ASAuthorizationController(authorizationRequests: [request])
      controller.delegate = self
      controller.presentationContextProvider = self
      controller.performRequests()
    }
  }

  private func randomNonceString(length: Int = 32) -> String {
    precondition(length > 0)
    let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
    var result = ""
    var remainingLength = length

    while remainingLength > 0 {
      var randoms: [UInt8] = []
      for _ in 0..<16 {
        var random: UInt8 = 0
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
        if errorCode != errSecSuccess {
          fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
        }
        randoms.append(random)
      }

      randoms.forEach { random in
        if remainingLength == 0 { return }
        if random < charset.count {
          result.append(charset[Int(random)])
          remainingLength -= 1
        }
      }
    }

    return result
  }

  private func sha256(_ input: String) -> String {
    let inputData = Data(input.utf8)
    let hashed = SHA256.hash(data: inputData)
    return hashed.map { String(format: "%02x", $0) }.joined()
  }

  private func formatDisplayName(_ components: PersonNameComponents?) -> String? {
    guard let components else { return nil }
    let formatter = PersonNameComponentsFormatter()
    let name = formatter.string(from: components).trimmingCharacters(in: .whitespacesAndNewlines)
    return name.isEmpty ? nil : name
  }
}

// MARK: - ASAuthorizationControllerDelegate
extension AppleOAuthRepository: ASAuthorizationControllerDelegate {
  public func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
    guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else {
      signInContinuation?.resume(throwing: AppleSignInError.authorizationFailed("Invalid credential type"))
      signInContinuation = nil
      return
    }

    guard let nonce = currentNonce else {
      signInContinuation?.resume(throwing: AppleSignInError.missingNonce)
      signInContinuation = nil
      return
    }

    guard let identityTokenData = credential.identityToken,
          let identityToken = String(data: identityTokenData, encoding: .utf8) else {
      signInContinuation?.resume(throwing: AppleSignInError.missingIDToken)
      signInContinuation = nil
      return
    }

    let displayName = formatDisplayName(credential.fullName)
    let authorizationCode = credential.authorizationCode.flatMap { String(data: $0, encoding: .utf8) }

    let payload = AppleOAuthPayload(
      idToken: identityToken,
      authorizationCode: authorizationCode,
      displayName: displayName,
      nonce: nonce
    )

    logger.info("Apple Sign In successful for user: \(displayName ?? "unknown")")
    signInContinuation?.resume(returning: payload)
    signInContinuation = nil
    currentNonce = nil
  }

  public func authorizationController(
    controller: ASAuthorizationController,
    didCompleteWithError error: Error
  ) {
    let nsError = error as NSError

    if nsError.code == ASAuthorizationError.canceled.rawValue {
      signInContinuation?.resume(throwing: AppleSignInError.userCancelled)
    } else {
      logger.error("Apple Sign In failed: \(error.localizedDescription)")
      signInContinuation?.resume(throwing: AppleSignInError.authorizationFailed(error.localizedDescription))
    }

    signInContinuation = nil
    currentNonce = nil
  }
}

// MARK: - ASAuthorizationControllerPresentationContextProviding
extension AppleOAuthRepository: ASAuthorizationControllerPresentationContextProviding {
  public func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
#if canImport(UIKit)
    return UIApplication.shared.connectedScenes
      .compactMap { ($0 as? UIWindowScene)?.keyWindow }
      .first ?? ASPresentationAnchor()
#else
    return ASPresentationAnchor()
#endif
  }
}
