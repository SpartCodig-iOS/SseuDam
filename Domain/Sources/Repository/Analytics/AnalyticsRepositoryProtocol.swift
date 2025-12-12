import Foundation

/// Analytics 이벤트 전송을 위한 Repository 프로토콜
public protocol AnalyticsRepositoryProtocol: Sendable {
    func sendEvent(_ event: AnalyticsEvent) async
}
