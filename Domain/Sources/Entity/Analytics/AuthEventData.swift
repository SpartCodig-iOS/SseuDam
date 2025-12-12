import Foundation

/// Authentication 이벤트 데이터
public struct AuthEventData: Sendable {
    public let socialType: String
    public let isFirst: Bool?

    public init(socialType: String, isFirst: Bool? = nil) {
        self.socialType = socialType
        self.isFirst = isFirst
    }
}

/// Authentication 이벤트 타입
public enum AuthEventType: String, Sendable {
    case loginSuccess = "login_success"
    case signupSuccess = "signup_success"
}