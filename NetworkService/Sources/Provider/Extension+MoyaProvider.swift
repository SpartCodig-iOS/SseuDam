//
//  Extension+MoyaProvider.swift
//  NetworkService
//
//  Created by Wonji Suh  on 11/17/25.
//

import Moya
import EventLimiter
import LogMacro

public extension MoyaProvider {
   func request<T: Decodable & Sendable>(
    _ target: Target,
    decodeTo type: T.Type
  ) async throws -> T {
    let throttle = Throttler(for: 0.3, latest: true)
    return try await withCheckedThrowingContinuation { continuation in
      throttle {
        // MoyaProvider를 사용해 비동기 요청 처리
        self.request(target) { result in
          let finalResult: Result<T, Error>
          switch result {
          case .success(let response):
            guard let httpResponse = response.response else {
              finalResult = .failure(NetworkError.noData)
              break
            }
            // HTTP 상태 코드에 따른 처리
            switch httpResponse.statusCode {
            case 200, 201, 204, 401:
              // 정상 상태 코드
              if response.data.isEmpty, T.self == Void.self {
                finalResult = .success(Void() as! T)
              } else {
                let decodeResult: Result<T, Error> = Result {
                  try response.data.decoded(as: T.self)
                }.mapError { error in
                  #logError("DecodingError occurred: \(error.localizedDescription)")
                  return MoyaError.underlying(error, nil)
                }
                finalResult = decodeResult
              }
            case 400:
              finalResult = .failure(MoyaError.statusCode(response))
            case 404:
              let errorDecodeResult: Result<ResponseError, Error> = Result {
                try response.data.decoded(as: ResponseError.self)
              }.mapError { error in
                return MoyaError.underlying(error, nil)
              }
              switch errorDecodeResult {
              case .success(let errorResponse):
                finalResult = .failure(NetworkError.customError(errorResponse))
              case .failure(let error):
                finalResult = .failure(error)
              }
            default:
              finalResult = .failure(NetworkError.unhandledStatusCode(httpResponse.statusCode))
            }

          case .failure(let error):
            finalResult = .failure(error)
          }
          // Result에 따라 continuation 종료

          switch finalResult {
          case .success(let value):
            continuation.resume(returning: value)
            #logNetwork("\(type) 데이터 통신", value)
          case .failure(let error):
            continuation.resume(throwing: error)
            #logError("네트워크 에러 발생: \(error.localizedDescription)")
          }
        }
      }
    }
  }
}

extension MoyaProvider {
  /// 기본 Provider (로그 플러그인만 포함)
  static var `default`: MoyaProvider {
    MoyaProvider(
      plugins: [
        MoyaLoggingPlugin()
      ]
    )
  }

  /// 커스텀 Alamofire.Session을 쓰는 Provider
  static func withSession(_ session: RequestInterceptor) -> MoyaProvider {
    MoyaProvider(
      session: Session(interceptor: session),
      plugins: [
        MoyaLoggingPlugin()
      ]
    )
  }
}
