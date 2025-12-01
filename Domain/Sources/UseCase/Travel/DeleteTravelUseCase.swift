//
//  DeleteTravelUseCase.swift
//  Domain
//
//  Created by 김민희 on 11/17/25.
//

import Foundation
import Dependencies

public protocol DeleteTravelUseCaseProtocol {
    func execute(id: String) async throws
}

final class DeleteTravelUseCase: DeleteTravelUseCaseProtocol {
    private let repository: TravelRepositoryProtocol
    
    init(repository: TravelRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(id: String) async throws {
        try await repository.deleteTravel(id: id)
    }
}

extension DeleteTravelUseCase: DependencyKey {
    public static var liveValue: DeleteTravelUseCaseProtocol = {
        DeleteTravelUseCase(repository: MockTravelRepository())
    }()

    public static var previewValue: DeleteTravelUseCaseProtocol = {
        DeleteTravelUseCase(repository: MockTravelRepository())
    }()

    public static var testValue: DeleteTravelUseCaseProtocol = {
        DeleteTravelUseCase(repository: MockTravelRepository())
    }()
}

public extension DependencyValues {
    var deleteTravelUseCase: DeleteTravelUseCaseProtocol {
        get { self[DeleteTravelUseCase.self] }
        set { self[DeleteTravelUseCase.self] = newValue }
    }
}
