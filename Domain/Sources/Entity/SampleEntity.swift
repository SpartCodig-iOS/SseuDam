import Foundation

public struct SampleEntity {
    public let id: UUID
    public let name: String
    public let createdAt: Date
    
    public init(
        id: UUID = UUID(),
        name: String,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.createdAt = createdAt
    }
}