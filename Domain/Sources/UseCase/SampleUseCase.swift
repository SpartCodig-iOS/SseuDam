import Foundation

public protocol SampleUseCaseInterface {
    func getSample(id: UUID) async throws -> SampleEntity
    func getAllSamples() async throws -> [SampleEntity]
    func createSample(name: String) async throws -> SampleEntity
    func updateSample(id: UUID, name: String) async throws -> SampleEntity
    func deleteSample(id: UUID) async throws
}

public final class SampleUseCase: SampleUseCaseInterface {
    private let repository: SampleRepositoryInterface
    
    public init(repository: SampleRepositoryInterface) {
        self.repository = repository
    }
    
    public func getSample(id: UUID) async throws -> SampleEntity {
        return try await repository.getSample(id: id)
    }
    
    public func getAllSamples() async throws -> [SampleEntity] {
        return try await repository.getAllSamples()
    }
    
    public func createSample(name: String) async throws -> SampleEntity {
        let entity = SampleEntity(name: name)
        return try await repository.createSample(entity)
    }
    
    public func updateSample(id: UUID, name: String) async throws -> SampleEntity {
        let entity = SampleEntity(id: id, name: name)
        return try await repository.updateSample(entity)
    }
    
    public func deleteSample(id: UUID) async throws {
        try await repository.deleteSample(id: id)
    }
}