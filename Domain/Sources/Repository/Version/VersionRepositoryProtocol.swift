//
//  VersionRepositoryProtocol.swift
//  Domain
//
//  Created by Wonji Suh  on 12/8/25.
//

import Foundation
import Dependencies

public protocol VersionRepositoryProtocol {
  func getVersion(bundleId: String, version: String) async throws -> Version
}

// MARK: - Dependencies
private struct VersionRepositoryDependencyKey: DependencyKey {
    public static var liveValue: VersionRepositoryProtocol {
        fatalError("VersionRepositoryDependency liveValue not implemented")
    }
    public static let previewValue: VersionRepositoryProtocol = MockVersionRepository()
    public static let testValue: VersionRepositoryProtocol = MockVersionRepository()
}

public extension DependencyValues {
    var versionRepository: VersionRepositoryProtocol {
        get { self[VersionRepositoryDependencyKey.self] }
        set { self[VersionRepositoryDependencyKey.self] = newValue }
    }
}
