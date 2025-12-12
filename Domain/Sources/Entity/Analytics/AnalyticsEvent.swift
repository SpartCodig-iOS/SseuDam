import Foundation

/// Analytics 이벤트 통합 enum
public enum AnalyticsEvent: Sendable {
    case auth(AuthEventType, AuthEventData)
    case deeplink(DeeplinkEventData)
    case travel(TravelEventType, TravelEventData)
    case expense(ExpenseEventType, ExpenseEventData)
}