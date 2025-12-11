import Foundation
import Dependencies

public protocol AnalyticsUseCaseProtocol: Sendable {
  func trackDeeplinkOpen(deeplink: String, type: String)
  func trackExpenseOpenDetail(travelId: String, expenseId: String, source: String)
  func trackLoginSuccess(socialType: String, isFirst: Bool?)
  func trackSignupSuccess(socialType: String)
  func trackTravelUpdate(_ travelId: String)
  func trackTravelDelete(_ travelId: String)
  func trackTravelLeave(travelId: String, userId: String?)
  func trackTravelMemberLeave(travelId: String, memberId: String, role: String?)
  func trackTravelOwnerDelegate(travelId: String, newOwnerId: String)
}

public struct AnalyticsUseCase: AnalyticsUseCaseProtocol {
  private let manager: any AnalyticsManaging
  
  public init(manager: any AnalyticsManaging) {
    self.manager = manager
  }
  
  public func trackDeeplinkOpen(deeplink: String, type: String) {
    manager.trackDeeplinkOpen(deeplink: deeplink, type: type)
  }
  
  public func trackExpenseOpenDetail(travelId: String, expenseId: String, source: String) {
    manager.trackExpenseOpenDetail(travelId: travelId, expenseId: expenseId, source: source)
  }
  
  public func trackLoginSuccess(socialType: String, isFirst: Bool?) {
    manager.trackLoginSuccess(socialType: socialType, isFirst: isFirst)
  }
  
  public func trackSignupSuccess(socialType: String) {
    manager.trackSignupSuccess(socialType: socialType)
  }
  
  public func trackTravelUpdate(_ travelId: String) {
    manager.trackTravelUpdate(travelId)
  }
  
  public func trackTravelDelete(_ travelId: String) {
    manager.trackTravelDelete(travelId)
  }
  
  public func trackTravelLeave(travelId: String, userId: String?) {
    manager.trackTravelLeave(travelId: travelId, userId: userId)
  }
  
  public func trackTravelMemberLeave(travelId: String, memberId: String, role: String?) {
    manager.trackTravelMemberLeave(travelId: travelId, memberId: memberId, role: role)
  }
  
  public func trackTravelOwnerDelegate(travelId: String, newOwnerId: String) {
    manager.trackTravelOwnerDelegate(travelId: travelId, newOwnerId: newOwnerId)
  }
}

private enum AnalyticsUseCaseKey: DependencyKey {
  static let liveValue: AnalyticsUseCaseProtocol = AnalyticsUseCase(manager: NoOpAnalyticsManager())
  static let testValue: AnalyticsUseCaseProtocol = AnalyticsUseCase(manager: NoOpAnalyticsManager())
}

public extension DependencyValues {
  var analyticsUseCase: AnalyticsUseCaseProtocol {
    get { self[AnalyticsUseCaseKey.self] }
    set { self[AnalyticsUseCaseKey.self] = newValue }
  }
}
