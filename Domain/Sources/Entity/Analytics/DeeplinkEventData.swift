import Foundation

/// Deeplink 이벤트 데이터
public struct DeeplinkEventData: Sendable {
    public let deeplink: String
    public let type: String

    public init(deeplink: String, type: String) {
        self.deeplink = deeplink
        self.type = type
    }
}