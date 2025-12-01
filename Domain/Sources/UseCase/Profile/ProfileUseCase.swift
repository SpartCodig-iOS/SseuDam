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
