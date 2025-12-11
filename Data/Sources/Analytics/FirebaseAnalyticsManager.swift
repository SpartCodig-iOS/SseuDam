import Foundation
import FirebaseAnalytics
import Domain
import LogMacro

/// FirebaseAnalytics를 사용해 이벤트를 전송하는 Live 구현체.
public class FirebaseAnalyticsManager: AnalyticsManaging, @unchecked Sendable {
    public init() {
        #logDebug("🔥 [Analytics] ===== FIREBASE ANALYTICS MANAGER INITIALIZED =====")
        #logDebug("🔥 [Analytics] Sending app_analytics_initialized event...")

        Analytics.logEvent("app_analytics_initialized", parameters: [
            "timestamp": Date().timeIntervalSince1970,
            "version": "1.0"
        ])
    }

    // MARK: - Deeplink / Expense
    public func trackDeeplinkOpen(deeplink: String, type: String) {
        let parameters: [String: Any] = [
            "deeplink": deeplink,
            "deeplink_type": type
        ]

        #logDebug("🔥 [Analytics] Parameters: \(parameters)")

        Analytics.logEvent("deeplink_open", parameters: parameters)

        #logDebug("🔥 [Analytics] ✅ deeplink_open event sent to Firebase")
    }

    public func trackExpenseOpenDetail(travelId: String, expenseId: String, source: String) {
        #logDebug("🔥 [Analytics] Parameters: travel_id=\(travelId), expense_id=\(expenseId), source=\(source)")

        Analytics.logEvent("expense_open_detail", parameters: [
            "travel_id": travelId,
            "expense_id": expenseId,
            "source": source
        ])
    }

    public func trackLoginSuccess(socialType: String, isFirst: Bool?) {
        var params: [String: Any] = ["social_type": socialType]
        if let isFirst { params["is_first"] = isFirst }
        #logDebug("🔥 [Analytics] Parameters: \(params)")

        Analytics.logEvent("login_success", parameters: params)
    }

    public func trackSignupSuccess(socialType: String) {
        let params = ["social_type": socialType]
        #logDebug("🔥 [Analytics] Parameters: \(params)")

        Analytics.logEvent("signup_success", parameters: params)
    }

    // MARK: - Travel
    public func trackTravelUpdate(_ travelId: String) {
        Analytics.logEvent("travel_update", parameters: [
            "travel_id": travelId
        ])
    }

    public func trackTravelDelete(_ travelId: String) {
        Analytics.logEvent("travel_delete", parameters: [
            "travel_id": travelId
        ])
    }

    public func trackTravelLeave(travelId: String, userId: String?) {
        var params: [String: Any] = ["travel_id": travelId]
        if let userId { params["user_id"] = userId }
        Analytics.logEvent("travel_leave", parameters: params)
    }

    public func trackTravelMemberLeave(travelId: String, memberId: String, role: String?) {
        var params: [String: Any] = [
            "travel_id": travelId,
            "member_id": memberId
        ]
        if let role { params["role"] = role }
        Analytics.logEvent("travel_member_leave", parameters: params)
    }

    public func trackTravelOwnerDelegate(travelId: String, newOwnerId: String) {
        let parameters: [String: Any] = [
            "travel_id": travelId,
            "new_owner_id": newOwnerId
        ]

        #logDebug("🔥 [Analytics] Parameters: \(parameters)")

        Analytics.logEvent("travel_owner_delegate", parameters: parameters)
    }

    // MARK: - Additional Events from CSV
    /// 지출 화면 진입 시 (expense_view)
    public func trackExpenseView(travelId: String, tab: String, expenseDate: String) {
        let parameters: [String: Any] = [
            "travel_id": travelId,
            "tab": tab,
            "expense_date": expenseDate
        ]
        #logDebug("🔥 [Analytics] Parameters: \(parameters)")

        Analytics.logEvent("expense_view", parameters: parameters)
    }

    /// 지출 생성 성공 시 (expense_create_success)
    public func trackExpenseCreateSuccess(
        travelId: String,
        expenseId: String,
        amount: Double,
        currency: String,
        category: String,
        payerId: String
    ) {
        let parameters: [String: Any] = [
            "travel_id": travelId,
            "expense_id": expenseId,
            "amount": amount,
            "currency": currency,
            "category": category,
            "payer_id": payerId
        ]
        #logDebug("🔥 [Analytics] Parameters: \(parameters)")

        Analytics.logEvent("expense_create_success", parameters: parameters)
    }

    /// 지출 생성 실패 시 (expense_create_failure)
    public func trackExpenseCreateFailure(
        travelId: String,
        amount: Double,
        currency: String,
        category: String,
        payerId: String,
        errorCode: String
    ) {
        let parameters: [String: Any] = [
            "travel_id": travelId,
            "amount": amount,
            "currency": currency,
            "category": category,
            "payer_id": payerId,
            "error_code": errorCode
        ]
        #logDebug("🔥 [Analytics] Parameters: \(parameters)")

        Analytics.logEvent("expense_create_failure", parameters: parameters)
    }

    /// 지출 수정 성공 시 (expense_update)
    public func trackExpenseUpdate(travelId: String, expenseId: String, amount: Double, currency: String, category: String, payerId: String) {
        let parameters: [String: Any] = [
            "travel_id": travelId,
            "expense_id": expenseId,
            "amount": amount,
            "currency": currency,
            "category": category,
            "payer_id": payerId
        ]
        #logDebug("🔥 [Analytics] Parameters: \(parameters)")

        Analytics.logEvent("expense_update", parameters: parameters)
    }

    /// 지출 삭제 성공 시 (expense_delete)
    public func trackExpenseDelete(travelId: String, expenseId: String, source: String) {
        let parameters: [String: Any] = [
            "travel_id": travelId,
            "expense_id": expenseId,
            "source": source
        ]
        #logDebug("🔥 [Analytics] Parameters: \(parameters)")

        Analytics.logEvent("expense_delete", parameters: parameters)
    }
}
