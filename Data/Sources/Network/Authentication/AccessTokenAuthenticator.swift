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

  private let repository: AuthRepository

  init(repository: AuthRepository = AuthRepository(provider: MoyaProvider<AuthAPITarget>.default)) {
    self.repository = repository
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
      let result = await refreshCredential(credential)
      completion(result)
    }
  }

  func didRequest(
    _ urlRequest: URLRequest,
    with response: HTTPURLResponse,
    failDueToAuthenticationError error: any Error
  ) -> Bool {
    response.statusCode == 401
  }

  func isRequest(
    _ urlRequest: URLRequest,
    authenticatedWith credential: Credential
  ) -> Bool {
    urlRequest.headers["Authorization"] == "Bearer \(credential.accessToken)"
  }
}

private extension AccessTokenAuthenticator {
  func refreshCredential(_ credential: Credential) async -> Result<Credential, any Error> {
    guard credential.refreshToken.isEmpty == false else {
      return .failure(TokenRefreshError.missingRefreshToken)
    }

    do {
      let result = try await repository.refresh(token: credential.refreshToken)
      let tokens = result.token

      KeychainManager.shared.saveTokens(
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken
      )

      guard
        let refreshedCredential = AccessTokenCredential.make(
          accessToken: tokens.accessToken,
          refreshToken: tokens.refreshToken ?? ""
        )
      else {
        return .failure(TokenRefreshError.invalidAccessToken)
      }

      return .success(refreshedCredential)
    } catch {
      return .failure(error)
    }
  }
}
