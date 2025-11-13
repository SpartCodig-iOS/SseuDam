import Testing
@testable import Domain

struct SampleUseCaseTests {
    private let mockRepository: MockSampleRepository
    private let useCase: SampleUseCase
    
    init() {
        mockRepository = MockSampleRepository()
        useCase = SampleUseCase(repository: mockRepository)
    }
    
    @Test
    func getSampleSuccess() async throws {
        // Given
        let expectedEntity = SampleEntity(name: "Test Sample")
        mockRepository.getSampleResult = expectedEntity
        
        // When
        let result = try await useCase.getSample(id: expectedEntity.id)
        
        // Then
        #expect(result.id == expectedEntity.id)
        #expect(result.name == expectedEntity.name)
    }
}

// MARK: - Mock Repository
private final class MockSampleRepository: SampleRepositoryInterface {
    var getSampleResult: SampleEntity?
    var getAllSamplesResult: [SampleEntity] = []
    var createSampleResult: SampleEntity?
    var updateSampleResult: SampleEntity?
    
    func getSample(id: UUID) async throws -> SampleEntity {
        guard let result = getSampleResult else {
            throw NSError(domain: "Mock", code: 0, userInfo: nil)
        }
        return result
    }
    
    func getAllSamples() async throws -> [SampleEntity] {
        return getAllSamplesResult
    }
    
    func createSample(_ entity: SampleEntity) async throws -> SampleEntity {
        return createSampleResult ?? entity
    }
    
    func updateSample(_ entity: SampleEntity) async throws -> SampleEntity {
        return updateSampleResult ?? entity
    }
    
    func deleteSample(id: UUID) async throws {
        // Mock implementation
    }
}