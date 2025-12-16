import Foundation
import Dependencies
/// Analytics 이벤트 전송을 위한 Repository 프로토콜
public protocol AnalyticsRepositoryProtocol: Sendable {
    func sendEvent(_ event: AnalyticsEvent) async
}

// MARK: - Dependencies
public struct AnalyticsRepositoryDependency: DependencyKey {
    public static var liveValue: AnalyticsRepositoryProtocol {
        fatalError("AnalyticsRepositoryDependency liveValue not implemented")
    }
    public static var previewValue: AnalyticsRepositoryProtocol = MockAnalyticsRepository()
    public static var testValue: AnalyticsRepositoryProtocol = MockAnalyticsRepository()
}

public extension DependencyValues {
    var analyticsRepository: AnalyticsRepositoryProtocol {
        get { self[AnalyticsRepositoryDependency.self] }
        set { self[AnalyticsRepositoryDependency.self] = newValue }
    }
}
