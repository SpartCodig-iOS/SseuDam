import Foundation
import FirebaseAnalytics
import Domain
import LogMacro
import Mixpanel

/// FirebaseAnalytics를 사용한 Analytics Repository 구현체
public class AnalyticsRepository: AnalyticsRepositoryProtocol, @unchecked Sendable {

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
            params["is_first"] = isFirst as Any
        }

        #logDebug("🔥 [Analytics] Parameters: \(params)")
        Analytics.logEvent(eventType.rawValue, parameters: params)
        Mixpanel.mainInstance().track(event: eventType.rawValue, properties: params as? [String: MixpanelType])
    }

    private func sendDeeplinkEvent(_ data: DeeplinkEventData) async {
        let parameters: [String: Any] = [
            "deeplink": data.deeplink,
            "deeplink_type": data.type
        ]

        #logDebug("🔥 [Analytics] Parameters: \(parameters)")
        Analytics.logEvent("deeplink_open", parameters: parameters)
        #logDebug("🔥 [Analytics] ✅ deeplink_open event sent to Firebase")
        Mixpanel.mainInstance().track(event: "deeplink_open", properties: parameters as? [String: MixpanelType])
    }

    private func sendTravelEvent(_ eventType: TravelEventType, _ data: TravelEventData) async {
        var params: [String: Any] = ["travel_id": data.travelId]

        // Optional fields based on event type
        if let userId = data.userId { params["user_id"] = userId as Any }
        if let memberId = data.memberId { params["member_id"] = memberId as Any }
        if let role = data.role { params["role"] = role as Any }
        if let newOwnerId = data.newOwnerId { params["new_owner_id"] = newOwnerId as Any }

        #logDebug("🔥 [Analytics] Parameters: \(params)")
        Analytics.logEvent(eventType.rawValue, parameters: params)
        Mixpanel.mainInstance().track(event: eventType.rawValue, properties: params as? [String: MixpanelType])
    }

    private func sendExpenseEvent(_ eventType: ExpenseEventType, _ data: ExpenseEventData) async {
        var params: [String: Any] = ["travel_id": data.travelId]

        // Add optional fields
        if let expenseId = data.expenseId { params["expense_id"] = expenseId as Any }
        if let amount = data.amount { params["amount"] = amount as Any }
        if let currency = data.currency { params["currency"] = currency as Any }
        if let category = data.category { params["category"] = category as Any }
        if let payerId = data.payerId { params["payer_id"] = payerId as Any }
        if let source = data.source { params["source"] = source as Any }
        if let tab = data.tab { params["tab"] = tab as Any }
        if let expenseDate = data.expenseDate { params["expense_date"] = expenseDate as Any }
        if let errorCode = data.errorCode { params["error_code"] = errorCode as Any }

        #logDebug("🔥 [Analytics] Parameters: \(params)")
        Analytics.logEvent(eventType.rawValue, parameters: params)
        Mixpanel.mainInstance().track(event: eventType.rawValue, properties: params as? [String: MixpanelType])
    }
}
