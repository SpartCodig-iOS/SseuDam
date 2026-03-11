//
//  AccessTokenAuthenticator.swift
//  Data
//
//  Created by Wonji Suh on 01/14/26.
//

import Foundation
import Alamofire
import Domain
import Moya

enum TokenRefreshError: Error {
  case missingRefreshToken
  case invalidAccessToken
}

final class AccessTokenAuthenticator: Authenticator {
  typealias Credential = AccessTokenCredential

  private let tokenRefreshManager: TokenRefreshManager

  init(remote: any AuthRemoteDataSourceProtocol = AuthRemoteDataSource(
    authProvider: MoyaProvider<AuthAPITarget>.default,
    oauthProvider: MoyaProvider<OAuthAPITarget>.default
  )) {
    self.tokenRefreshManager = TokenRefreshManager(remote: remote)
  }

  func apply(_ credential: Credential, to urlRequest: inout URLRequest) {
    urlRequest.headers.add(.authorization(bearerToken: credential.accessToken))
  }

  func refresh(
    _ credential: Credential,
    for session: Session,
    completion: @escaping @Sendable (Result<Credential, any Error>) -> Void
  ) {
    _Concurrency.Task {
      do {
        let refreshedCredential = try await tokenRefreshManager.refreshCredentialIfNeeded(current: credential)
        completion(.success(refreshedCredential))
      } catch {
        completion(.failure(error))
      }
    }
  }

  func didRequest(
    _ urlRequest: URLRequest,
    with response: HTTPURLResponse,
    failDueToAuthenticationError error: any Error
  ) -> Bool {
    // First check HTTP status code
    if response.statusCode == 401 {
      return true
    }

    // Enhanced 401 detection logic (sync version)
    return isRefreshTokenExpiredError(error)
  }

  func isRequest(
    _ urlRequest: URLRequest,
    authenticatedWith credential: Credential
  ) -> Bool {
    urlRequest.headers["Authorization"] == "Bearer \(credential.accessToken)"
  }
}

// MARK: - Enhanced Error Detection
private extension AccessTokenAuthenticator {
  /// Enhanced 401 detection with multiple layers (sync version)
  func isRefreshTokenExpiredError(_ error: Error) -> Bool {
    // 1. Check string description for "statusCodeError(401)"
    if String(describing: error).contains("statusCodeError(401)") {
      return true
    }

    // 2. Check Moya MoyaError.statusCode
    if let moyaError = error as? MoyaError {
      switch moyaError {
      case .statusCode(let response) where response.statusCode == 401:
        return true
      case .underlying(_, let response) where response?.statusCode == 401:
        return true
      default:
        break
      }
    }

    // 3. Check AuthError.isTokenExpiredError
    if let authError = error as? AuthError {
      return authError.isTokenExpiredError
    }

    // 4. Check error message keywords
    let errorDesc = error.localizedDescription.lowercased()
    if errorDesc.contains("401") ||
       errorDesc.contains("unauthorized") ||
       errorDesc.contains("유효하지 않은 토큰") {
      return true
    }

    return false
  }
}

