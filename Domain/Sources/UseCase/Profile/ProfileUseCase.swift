//
//  ProfileUseCase.swift
//  Domain
//
//  Created by Wonji Suh  on 12/1/25.
//

import Foundation
import ComposableArchitecture

public struct ProfileUseCase: ProfileUseCaseProtocol {
  private let repository: ProfileRepositoryProtocol
  
  public init(repository: ProfileRepositoryProtocol) {
    self.repository = repository
  }

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
    public static var liveValue: ProfileUseCaseProtocol {
        return ProfileUseCase(repository: MockProfileRepository())
    }

    public static var previewValue: any ProfileUseCaseProtocol { liveValue }

    public static let testValue: ProfileUseCaseProtocol = ProfileUseCase(
        repository: MockProfileRepository()
    )
}


public extension DependencyValues {
    var profileUseCase : ProfileUseCaseProtocol {
        get { self[ProfileUseCase.self] }
        set { self[ProfileUseCase.self] = newValue }
    }
}
