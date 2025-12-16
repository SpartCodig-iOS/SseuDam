//
//  ProfileRepositoryProtocol.swift
//  Domain
//
//  Created by Wonji Suh  on 12/1/25.
//

import Foundation
import Dependencies

public protocol ProfileRepositoryProtocol {
    func getProfile() async throws -> Profile
    func editProfile(name: String?, avatarData: Data?, fileName: String?) async throws -> Profile
}

// MARK: - Dependencies
private struct ProfileRepositoryDependencyKey: DependencyKey {
    public static var liveValue: ProfileRepositoryProtocol {
        fatalError("ProfileRepositoryDependency liveValue not implemented")
    }
    public static var previewValue: ProfileRepositoryProtocol = MockProfileRepository()
    public static var testValue: ProfileRepositoryProtocol = MockProfileRepository()
}

public extension DependencyValues {
    var profileRepository: ProfileRepositoryProtocol {
        get { self[ProfileRepositoryDependencyKey.self] }
        set { self[ProfileRepositoryDependencyKey.self] = newValue }
    }
}
