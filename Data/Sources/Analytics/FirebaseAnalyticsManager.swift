import Foundation
import FirebaseAnalytics
import Domain
import LogMacro

/// FirebaseAnalytics를 사용한 Analytics Repository 구현체
public class FirebaseAnalyticsRepository: AnalyticsRepositoryProtocol, @unchecked Sendable {

    public init() {
        #logDebug("🔥 [Analytics] ===== FIREBASE ANALYTICS REPOSITORY INITIALIZED =====")
        #logDebug("🔥 [Analytics] Sending app_analytics_initialized event...")

        Analytics.logEvent("app_analytics_initialized", parameters: [
            "timestamp": Date().timeIntervalSince1970,
            "version": "1.0"
        ])
    }

    public func sendEvent(_ event: AnalyticsEvent) async {
        switch event {
        case .auth(let eventType, let data):
            await sendAuthEvent(eventType, data)
        case .deeplink(let data):
            await sendDeeplinkEvent(data)
        case .travel(let eventType, let data):
            await sendTravelEvent(eventType, data)
        case .expense(let eventType, let data):
            await sendExpenseEvent(eventType, data)
        }
    }

    // MARK: - Private Event Handlers

    private func sendAuthEvent(_ eventType: AuthEventType, _ data: AuthEventData) async {
        var params: [String: Any] = ["social_type": data.socialType]
        if let isFirst = data.isFirst {
            params["is_first"] = isFirst
        }

        #logDebug("🔥 [Analytics] Parameters: \(params)")
        Analytics.logEvent(eventType.rawValue, parameters: params)
    }

    private func sendDeeplinkEvent(_ data: DeeplinkEventData) async {
        let parameters: [String: Any] = [
            "deeplink": data.deeplink,
            "deeplink_type": data.type
        ]

        #logDebug("🔥 [Analytics] Parameters: \(parameters)")
        Analytics.logEvent("deeplink_open", parameters: parameters)
        #logDebug("🔥 [Analytics] ✅ deeplink_open event sent to Firebase")
    }

    private func sendTravelEvent(_ eventType: TravelEventType, _ data: TravelEventData) async {
        var params: [String: Any] = ["travel_id": data.travelId]

        // Optional fields based on event type
        if let userId = data.userId { params["user_id"] = userId }
        if let memberId = data.memberId { params["member_id"] = memberId }
        if let role = data.role { params["role"] = role }
        if let newOwnerId = data.newOwnerId { params["new_owner_id"] = newOwnerId }

        #logDebug("🔥 [Analytics] Parameters: \(params)")
        Analytics.logEvent(eventType.rawValue, parameters: params)
    }

    private func sendExpenseEvent(_ eventType: ExpenseEventType, _ data: ExpenseEventData) async {
        var params: [String: Any] = ["travel_id": data.travelId]

        // Add optional fields
        if let expenseId = data.expenseId { params["expense_id"] = expenseId }
        if let amount = data.amount { params["amount"] = amount }
        if let currency = data.currency { params["currency"] = currency }
        if let category = data.category { params["category"] = category }
        if let payerId = data.payerId { params["payer_id"] = payerId }
        if let source = data.source { params["source"] = source }
        if let tab = data.tab { params["tab"] = tab }
        if let expenseDate = data.expenseDate { params["expense_date"] = expenseDate }
        if let errorCode = data.errorCode { params["error_code"] = errorCode }

        #logDebug("🔥 [Analytics] Parameters: \(params)")
        Analytics.logEvent(eventType.rawValue, parameters: params)
    }
}
