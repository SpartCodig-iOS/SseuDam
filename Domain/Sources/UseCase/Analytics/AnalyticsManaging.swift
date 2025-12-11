import Foundation
import Dependencies

/// Analytics 전송을 위한 프로토콜. 도메인/피처에서 의존성 주입으로 사용합니다.
public protocol AnalyticsManaging: Sendable {
    // Deeplink / Expense
    func trackDeeplinkOpen(deeplink: String, type: String)
    func trackExpenseOpenDetail(travelId: String, expenseId: String, source: String)
    func trackLoginSuccess(socialType: String, isFirst: Bool?)
    func trackSignupSuccess(socialType: String)

    // Travel
    func trackTravelUpdate(_ travelId: String)
    func trackTravelDelete(_ travelId: String)
    func trackTravelLeave(travelId: String, userId: String?)
    func trackTravelMemberLeave(travelId: String, memberId: String, role: String?)
    func trackTravelOwnerDelegate(travelId: String, newOwnerId: String)

    // Additional Events from CSV
    func trackExpenseView(travelId: String, tab: String, expenseDate: String)
    func trackExpenseCreateSuccess(travelId: String, expenseId: String, amount: Double, currency: String, category: String, payerId: String)
    func trackExpenseCreateFailure(travelId: String, amount: Double, currency: String, category: String, payerId: String, errorCode: String)
    func trackExpenseUpdate(travelId: String, expenseId: String, amount: Double, currency: String, category: String, payerId: String)
    func trackExpenseDelete(travelId: String, expenseId: String, source: String)
}

public struct NoOpAnalyticsManager: AnalyticsManaging {
    public init() {}
    public func trackDeeplinkOpen(deeplink: String, type: String) {}
    public func trackExpenseOpenDetail(travelId: String, expenseId: String, source: String) {}
    public func trackLoginSuccess(socialType: String, isFirst: Bool?) {}
    public func trackSignupSuccess(socialType: String) {}
    public func trackTravelUpdate(_ travelId: String) {}
    public func trackTravelDelete(_ travelId: String) {}
    public func trackTravelLeave(travelId: String, userId: String?) {}
    public func trackTravelMemberLeave(travelId: String, memberId: String, role: String?) {}
    public func trackTravelOwnerDelegate(travelId: String, newOwnerId: String) {}
    public func trackExpenseView(travelId: String, tab: String, expenseDate: String) {}
    public func trackExpenseCreateSuccess(travelId: String, expenseId: String, amount: Double, currency: String, category: String, payerId: String) {}
    public func trackExpenseCreateFailure(travelId: String, amount: Double, currency: String, category: String, payerId: String, errorCode: String) {}
    public func trackExpenseUpdate(travelId: String, expenseId: String, amount: Double, currency: String, category: String, payerId: String) {}
    public func trackExpenseDelete(travelId: String, expenseId: String, source: String) {}
}

private enum AnalyticsManagerKey: DependencyKey {
    static let liveValue: any AnalyticsManaging = NoOpAnalyticsManager()
    static let testValue: any AnalyticsManaging = NoOpAnalyticsManager()
}

public extension DependencyValues {
    var analyticsManager: any AnalyticsManaging {
        get { self[AnalyticsManagerKey.self] }
        set { self[AnalyticsManagerKey.self] = newValue }
    }
}
