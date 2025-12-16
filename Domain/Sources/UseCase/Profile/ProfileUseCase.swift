//
//  ProfileUseCase.swift
//  Domain
//
//  Created by Wonji Suh  on 12/1/25.
//

import Foundation
import Dependencies

public struct ProfileUseCase: ProfileUseCaseProtocol {
    @Dependency(\.profileRepository) private var repository: ProfileRepositoryProtocol
    
    public init() {}
    
    public func getProfile() async throws -> Profile {
        return try await repository.getProfile()
    }
    
    public func editProfile(_ payload: ProfileEditPayload) async throws -> Profile {
        let resolvedFileName: String? = {
            // 파일이 있을 때만 기본 파일명을 지정하고, 없으면 그대로 nil 전달
            guard payload.avatarData != nil else { return nil }
            return payload.fileName ?? "avatar.jpg"
        }()
        
        return try await repository.editProfile(
            name: payload.name,
            avatarData: payload.avatarData,
            fileName: resolvedFileName
        )
    }
}


extension ProfileUseCase: DependencyKey {
    public static let liveValue: ProfileUseCaseProtocol = ProfileUseCase()
    public static let previewValue: any ProfileUseCaseProtocol = ProfileUseCase()
    public static let testValue: ProfileUseCaseProtocol = ProfileUseCase()
}


public extension DependencyValues {
    var profileUseCase : ProfileUseCaseProtocol {
        get { self[ProfileUseCase.self] }
        set { self[ProfileUseCase.self] = newValue }
    }
}
