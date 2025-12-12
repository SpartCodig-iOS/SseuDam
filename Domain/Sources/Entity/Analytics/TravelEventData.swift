import Foundation

/// Travel 이벤트 데이터
public struct TravelEventData: Sendable {
    public let travelId: String
    public let userId: String?
    public let memberId: String?
    public let role: String?
    public let newOwnerId: String?

    public init(
        travelId: String,
        userId: String? = nil,
        memberId: String? = nil,
        role: String? = nil,
        newOwnerId: String? = nil
    ) {
        self.travelId = travelId
        self.userId = userId
        self.memberId = memberId
        self.role = role
        self.newOwnerId = newOwnerId
    }
}

/// Travel 이벤트 타입
public enum TravelEventType: String, Sendable {
    case update = "travel_update"
    case delete = "travel_delete"
    case leave = "travel_leave"
    case memberLeave = "travel_member_leave"
    case ownerDelegate = "travel_owner_delegate"
}