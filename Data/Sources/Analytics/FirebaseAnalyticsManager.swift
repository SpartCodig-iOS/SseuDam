import Foundation
import FirebaseAnalytics
import Domain
import LogMacro

/// FirebaseAnalytics를 사용해 이벤트를 전송하는 Live 구현체.
public class FirebaseAnalyticsManager: AnalyticsManaging, @unchecked Sendable {
    public init() {
        Analytics.logEvent("app_analytics_initialized", parameters: [
            "timestamp": Date().timeIntervalSince1970,
            "version": "1.0"
        ])
        #logDebug("🔥 [Analytics] Test event app_analytics_initialized sent")
    }
    
    // MARK: - Deeplink / Expense
    public func trackDeeplinkOpen(deeplink: String, type: String) {
        Analytics.logEvent("deeplink_open", parameters: [
            "deeplink": deeplink,
            "deeplink_type": type
        ])
    }
    
    public func trackExpenseOpenDetail(travelId: String, expenseId: String, source: String) {
        Analytics.logEvent("expense_open_detail", parameters: [
            "travel_id": travelId,
            "expense_id": expenseId,
            "source": source
        ])
    }
    
    public func trackLoginSuccess(socialType: String, isFirst: Bool?) {
        var params: [String: Any] = ["social_type": socialType]
        if let isFirst { params["is_first"] = isFirst }
        #logDebug("🔥 [Analytics] Tracking login_success: \(params)")
        Analytics.logEvent("login_success", parameters: params)
        #logDebug("🔥 [Analytics] login_success event sent to Firebase")
    }
    
    public func trackSignupSuccess(socialType: String) {
        let params = ["social_type": socialType]
        #logDebug("🔥 [Analytics] Tracking signup_success: \(params)")
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
        Analytics.logEvent("travel_owner_delegate", parameters: [
            "travel_id": travelId,
            "new_owner_id": newOwnerId
        ])
    }
}
