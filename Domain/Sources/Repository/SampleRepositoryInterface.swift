import Foundation

public protocol SampleRepositoryInterface {
    func getSample(id: UUID) async throws -> SampleEntity
    func getAllSamples() async throws -> [SampleEntity]
    func createSample(_ entity: SampleEntity) async throws -> SampleEntity
    func updateSample(_ entity: SampleEntity) async throws -> SampleEntity
    func deleteSample(id: UUID) async throws
}