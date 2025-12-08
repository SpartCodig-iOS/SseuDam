//
//  VersionUseCase.swift
//  Domain
//
//  Created by Wonji Suh  on 12/8/25.
//

import Foundation
import ComposableArchitecture

public struct VersionUseCase: VersionUseCaseProtocol {
    private let repository: VersionRepositoryProtocol
    
    public init(repository: VersionRepositoryProtocol) {
        self.repository = repository
    }
    
    public func getVersion(bundleId: String, version: String) async throws -> Version {
        return try await repository.getVersion(bundleId: bundleId, version: version)
    }
}

extension VersionUseCase: DependencyKey {
    public static var liveValue: VersionUseCaseProtocol {
        return VersionUseCase(repository: MockVersionRepository())
    }
    
    public static var previewValue: VersionUseCaseProtocol { liveValue }
    
    public static let testValue: VersionUseCaseProtocol = VersionUseCase(
        repository: MockVersionRepository()
    )
}


public extension DependencyValues {
    var versionUseCase : VersionUseCaseProtocol {
        get { self[VersionUseCase.self] }
        set { self[VersionUseCase.self] = newValue }
    }
}


