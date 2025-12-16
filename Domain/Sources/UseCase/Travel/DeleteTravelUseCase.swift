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

public struct DeleteTravelUseCase: DeleteTravelUseCaseProtocol {
    @Dependency(\.travelRepository) private var repository: TravelRepositoryProtocol
    
    public init() {}
    
    public func execute(id: String) async throws {
        try await repository.deleteTravel(id: id)
    }
}

extension DeleteTravelUseCase: DependencyKey {
    public static var liveValue: DeleteTravelUseCaseProtocol = DeleteTravelUseCase()
    public static var previewValue: DeleteTravelUseCaseProtocol = DeleteTravelUseCase()
    public static var testValue: DeleteTravelUseCaseProtocol = DeleteTravelUseCase()
}

public extension DependencyValues {
    var deleteTravelUseCase: DeleteTravelUseCaseProtocol {
        get { self[DeleteTravelUseCase.self] }
        set { self[DeleteTravelUseCase.self] = newValue }
    }
}
