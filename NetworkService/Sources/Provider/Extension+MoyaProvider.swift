//
//  Extension+MoyaProvider.swift
//  NetworkService
//
//  Created by Wonji Suh  on 11/17/25.
//

import Moya
import LogMacro

public extension MoyaProvider {
  func request<T: Decodable & Sendable>(_ target: Target) async throws -> T {
    try await withCheckedThrowingContinuation { continuation in
      self.request(target) { result in
        let finalResult: Result<T, Error> = Self.mapResponse(result)
        continuation.resume(with: finalResult)
      }
    }
  }

  private static func mapResponse<T: Decodable & Sendable>(
    _ result: Result<Response, MoyaError>
  ) -> Result<T, Error> {
    switch result {
    case .success(let response):
      guard let httpResponse = response.response else {
        return .failure(NetworkError.noResponse)
      }

      let statusCode = httpResponse.statusCode

      switch statusCode {
      case 200..<400:
        if T.self == Void.self || response.data.isEmpty {
          if let value = () as? T {
//            #logNetwork("\(T.self) 데이터 통신 (Void)", "")
            return .success(value)
          } else {
            return .failure(
              NetworkError.decodingError(
                underlying: NSError(
                  domain: "Network",
                  code: -1,
                  userInfo: [NSLocalizedDescriptionKey: "응답이 없는데 Void 이외의 타입으로 디코딩하려고 했습니다."]
                )
              )
            )
          }
        } else {
          do {
            let decoded: T = try response.data.decoded(as: T.self)
//            #logNetwork("\(T.self) 데이터 통신", decoded)
            return .success(decoded)
          } catch {
//            #logError("DecodingError occurred: \(error.localizedDescription)")
            return .failure(NetworkError.decodingError(underlying: error))
          }
        }

      case 400..<500:
        if let errorResponse = try? response.data.decoded(as: ResponseError.self) {
          return .failure(NetworkError.server(errorResponse))
        } else {
          return .failure(NetworkError.clientError(statusCode: statusCode))
        }

      case 500..<600:
        return .failure(NetworkError.serverError(statusCode: statusCode))

      default:
        return .failure(NetworkError.unknown(statusCode: statusCode))
      }

    case .failure(let moyaError):
//      #logError("네트워크 에러 발생: \(moyaError.localizedDescription)")
      return .failure(NetworkError.underlying(moyaError))
    }
  }
}

public extension MoyaProvider {
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
