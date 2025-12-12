import Foundation

/// Mock Analytics Repository for testing
public actor MockAnalyticsRepository: AnalyticsRepositoryProtocol, Sendable {

    // MARK: - Tracking

    private let eventsStorage = ThreadSafeContainer<[AnalyticsEvent]>([])

    /// 추적된 이벤트들 (테스트에서 확인용)
    public var trackedEvents: [AnalyticsEvent] {
        eventsStorage.value
    }

    public init() {}

    public func sendEvent(_ event: AnalyticsEvent) async {
        eventsStorage.modify { $0.append(event) }
    }

    /// 추적된 이벤트 초기화 (테스트 간 클린업용)
    public func clearTrackedEvents() {
        eventsStorage.modify { $0.removeAll() }
    }

    /// 특정 타입의 이벤트가 추적되었는지 확인
    public func hasTrackedEvent<T>(type: T.Type) -> Bool {
        return trackedEvents.contains { event in
            switch event {
            case .auth:
                return T.self == AuthEventType.self
            case .travel:
                return T.self == TravelEventType.self
            case .expense:
                return T.self == ExpenseEventType.self
            case .deeplink:
                return T.self == DeeplinkEventData.self
            }
        }
    }

    /// Auth 이벤트 추적 개수
    public var authEventCount: Int {
        trackedEvents.filter {
            if case .auth = $0 { return true }
            return false
        }.count
    }

    /// Travel 이벤트 추적 개수
    public var travelEventCount: Int {
        trackedEvents.filter {
            if case .travel = $0 { return true }
            return false
        }.count
    }

    /// Expense 이벤트 추적 개수
    public var expenseEventCount: Int {
        trackedEvents.filter {
            if case .expense = $0 { return true }
            return false
        }.count
    }

    /// Deeplink 이벤트 추적 개수
    public var deeplinkEventCount: Int {
        trackedEvents.filter {
            if case .deeplink = $0 { return true }
            return false
        }.count
    }
}

// MARK: - Thread Safety Helper

private class ThreadSafeContainer<T>: @unchecked Sendable {
    private var storage: T
    private let lock = NSLock()

    var value: T {
        lock.withLock { storage }
    }

    init(_ value: T) {
        self.storage = value
    }

    func modify(_ transform: (inout T) -> Void) {
        lock.withLock {
            transform(&storage)
        }
    }
}
