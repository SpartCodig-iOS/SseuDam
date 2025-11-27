//
//  AuthInterceptor.swift
//  Data
//
//  Created by Wonji Suh  on 11/28/25.
//

import Alamofire
import Moya
import Foundation
import Domain
import LogMacro

public final actor AuthInterceptor: RequestInterceptor {
  public static let shared = AuthInterceptor()

  private init() {}

  // Request를 수정하여 토큰을 추가하는 메서드
  public nonisolated func adapt(
    _ urlRequest: URLRequest,
    for session: Session,
    completion: @escaping (Result<URLRequest, Error>) -> Void
  ) async {
    guard urlRequest.url?.absoluteString.hasPrefix(BaseAPI.base.description) == true else {
      completion(.success(urlRequest))
      return
    }

    let accessToken = KeychainManager.shared.loadAccessToken() ?? ""
    var urlRequest = urlRequest

    urlRequest.setValue(accessToken, forHTTPHeaderField: "Authorization")

    Log.debug("Adapted request with headers: ", urlRequest.headers)
    completion(.success(urlRequest))
  }

  public nonisolated func retry(
    _ request: Request,
    for session: Session,
    dueTo error: Error,
    completion: @escaping (RetryResult) -> Void) async {
      Log.debug("Entered retry function")
      typealias Task = _Concurrency.Task
      // error의 상세 정보를 확인
      if let afError = error.asAFError, afError.isResponseValidationError {
        Log.error("Response validation error detected.")
      } else {
        Log.error("Error is not responseValidationFailed: \(error)")
      }

      // 401 상태 코드 확인
      guard let response = request.task?.response as? HTTPURLResponse else {
        Log.debug("Response is not an HTTPURLResponse.")
        completion(.doNotRetryWithError(error))
        return
      }

      Log.debug("HTTP Status Code: \(response.statusCode)")

      switch response.statusCode {
      case 400, 401:
        Log.debug("401 Unauthorized detected, attempting to refresh token...")
        Task {
          let retryResult = await RequestInterceptorManger.shared.refreshToken()
          completion(retryResult)
        }
      default:
        Log.debug("Status code is not 401, not retrying.")
        completion(.doNotRetryWithError(error))
      }
    }
}
