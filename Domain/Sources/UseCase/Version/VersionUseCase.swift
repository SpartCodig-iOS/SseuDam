//
//  VersionUseCase.swift
//  Domain
//
//  Created by Wonji Suh  on 12/8/25.
//

import Foundation
import Dependencies

public struct VersionUseCase: VersionUseCaseProtocol {
    @Dependency(\.versionRepository) private var repository: VersionRepositoryProtocol
    
    public init() {}
    
    public func getVersion(bundleId: String, version: String) async throws -> Version {
        return try await repository.getVersion(bundleId: bundleId, version: version)
    }
}

private struct VersionUseCaseDependencyKey: DependencyKey {
    public static let liveValue: VersionUseCaseProtocol = VersionUseCase()
    public static let previewValue: VersionUseCaseProtocol = VersionUseCase()
    public static let testValue: VersionUseCaseProtocol = VersionUseCase()
}

public extension DependencyValues {
    var versionUseCase : VersionUseCaseProtocol {
        get { self[VersionUseCaseDependencyKey.self] }
        set { self[VersionUseCaseDependencyKey.self] = newValue }
    }
}


