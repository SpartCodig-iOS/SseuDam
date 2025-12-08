//
//  MoyaLoggingPlugin.swift
//  NetworkService
//
//  Created by Wonji Suh  on 11/17/25.
//

import Moya
import LogMacro

public class MoyaLoggingPlugin: PluginType {
    /// 플러그인 인스턴스를 생성합니다.
    public init() {}
    
    /// 전송될 `URLRequest`를 수정할 수 있습니다.
    ///
    /// - Parameters:
    ///   - request: 전송 직전의 `URLRequest` 객체
    ///   - target: 요청할 API 엔드포인트를 나타내는 `TargetType`
    /// - Returns: 실제로 전송할 `URLRequest`
    public func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        return request
    }
    
    /// 요청이 전송되기 직전에 호출됩니다.
    ///
    /// HTTP 메서드, URL, 헤더, 요청 본문을 `Log.network`로 로깅합니다.
    ///
    /// - Parameters:
    ///   - request: 래핑된 `RequestType` 객체
    ///   - target: API 엔드포인트를 나타내는 `TargetType`
    
    public func willSend(_ request: RequestType, target: TargetType) {
        guard let httpRequest = request.request else {
#if DEBUG
            #logNetwork("❌ 유효하지 않은 요청입니다.", (Any).self)
#endif
            return
        }
        
        let method = httpRequest.httpMethod ?? "알 수 없는 HTTP 메서드"
        let url = httpRequest.url?.absoluteString ?? httpRequest.description
        
        var log = """
    
    ╔════════════════════════════════════════════════════════════════
    ║ 📤 REQUEST
    ╠════════════════════════════════════════════════════════════════
    ║ Method: \(method)
    ║ URL: \(url)
    ║ Target: \(target)
    """
        
        if let headers = httpRequest.allHTTPHeaderFields, !headers.isEmpty {
            log.append("\n╠────────────────────────────────────────────────────────────────")
            log.append("\n║ 📋 Headers:")
            for (key, value) in headers.sorted(by: { $0.key < $1.key }) {
                log.append("\n║   • \(key): \(value)")
            }
        }
        
        if let body = httpRequest.httpBody,
           let bodyString = String(data: body, encoding: .utf8) {
            log.append("\n╠────────────────────────────────────────────────────────────────")
            log.append("\n║ 📦 Body:")
            let formattedBody = formatJSON(bodyString)
            log.append("\n\(formattedBody.split(separator: "\n").map { "║   \($0)" }.joined(separator: "\n"))")
        }
        
        log.append("\n╚════════════════════════════════════════════════════════════════\n")
        
#if DEBUG
        #logNetwork(log, (Any).self)
#endif
    }
    
    /// 응답을 받았을 때 호출됩니다.
    ///
    /// 성공 또는 실패 결과를 `onSucceed` 또는 `onFail`로 전달하여 로깅합니다.
    ///
    /// - Parameters:
    ///   - result: 성공 시 `Response`, 실패 시 `MoyaError`를 포함한 `Result`
    ///   - target: API 엔드포인트를 나타내는 `TargetType`
    public func didReceive(_ result: Result<Response, MoyaError>, target: TargetType) {
        switch result {
        case let .success(response):
            onSucceed(response, target: target, isFromError: false)
        case let .failure(error):
            onFail(error, target: target)
        }
    }
    
    /// 응답을 처리하고 결과를 호출자에게 그대로 전달합니다.
    ///
    /// - Parameters:
    ///   - result: 원본 `Result<Response, MoyaError>`
    ///   - target: API 엔드포인트를 나타내는 `TargetType`
    /// - Returns: 호출자에게 전달할 동일한 `Result`
    public func process(_ result: Result<Response, MoyaError>, target: TargetType) -> Result<Response, MoyaError> {
        return result
    }
    
    /// 성공 응답을 로깅합니다.
    ///
    /// - Parameters:
    ///   - response: 성공적으로 받은 `Response` 객체
    ///   - target: API 엔드포인트를 나타내는 `TargetType`
    ///   - isFromError: 에러 핸들러에서 전달된 응답인지 여부
    public func onSucceed(_ response: Response, target: TargetType, isFromError: Bool) {
        let urlString = response.request?.url?.absoluteString ?? "알 수 없는 URL"
        let statusCode = response.statusCode
        let statusEmoji = statusCode < 300 ? "✅" : "⚠️"
        
        var log = """
    
    ╔════════════════════════════════════════════════════════════════
    ║ \(statusEmoji) RESPONSE \(isFromError ? "(From Error)" : "")
    ╠════════════════════════════════════════════════════════════════
    ║ Status: \(statusCode) \(HTTPURLResponse.localizedString(forStatusCode: statusCode))
    ║ URL: \(urlString)
    ║ Target: \(target)
    ║ Size: \(ByteCountFormatter.string(fromByteCount: Int64(response.data.count), countStyle: .file))
    """
        
        if let dataString = String(data: response.data, encoding: .utf8) {
            log.append("\n╠────────────────────────────────────────────────────────────────")
            log.append("\n║ 📦 Response Data:")
            let formattedData = formatJSON(dataString)
            log.append("\n\(formattedData.split(separator: "\n").map { "║   \($0)" }.joined(separator: "\n"))")
        }
        
        log.append("\n╚════════════════════════════════════════════════════════════════\n")
        
#if DEBUG
        #logNetwork(log, (Any).self)
#endif
    }
    
    /// 실패 에러를 로깅합니다.
    ///
    /// - Parameters:
    ///   - error: 발생한 `MoyaError`
    ///   - target: API 엔드포인트를 나타내는 `TargetType`
    public func onFail(_ error: MoyaError, target: TargetType) {
        if let response = error.response {
            // 응답을 포함한 에러는 성공 로깅으로 처리
            onSucceed(response, target: target, isFromError: true)
            return
        }
        
        let log = """
    
    ╔════════════════════════════════════════════════════════════════
    ║ ❌ NETWORK ERROR
    ╠════════════════════════════════════════════════════════════════
    ║ Error Code: \(error.errorCode)
    ║ Target: \(target)
    ║ Reason: \(error.failureReason ?? error.errorDescription ?? "알 수 없는 오류")
    ╚════════════════════════════════════════════════════════════════
    
    """
        
#if DEBUG
        #logError(log)
#endif
    }
    
    // MARK: - Helper Methods
    
    private func formatJSON(_ jsonString: String) -> String {
        guard let data = jsonString.data(using: .utf8),
              let jsonObject = try? JSONSerialization.jsonObject(with: data),
              let prettyData = try? JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted, .sortedKeys]),
              let prettyString = String(data: prettyData, encoding: .utf8) else {
            return jsonString
        }
        return prettyString
    }
}

