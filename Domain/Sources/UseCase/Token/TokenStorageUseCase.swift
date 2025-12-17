//
//  TokenStorageUseCase.swift
//  Domain
//
//  Created by Wonji Suh  on 12/17/25.
//

import LogMacro
import ComposableArchitecture

public struct TokenStorageUseCase: TokenStorageUseCaseProtocol {
  @Dependency(\.sessionStoreRepository) var sessionStore: any SessionStoreRepositoryProtocol
  
  
  public init() {}
  
  public func save(auth: AuthResult) async {
    await sessionStore.save(
      tokens: auth.token,
      socialType: auth.provider,
      userId: auth.userId
    )
  }
}


extension TokenStorageUseCase: DependencyKey {
  public static var liveValue: TokenStorageUseCase = TokenStorageUseCase()
  public static var testValue: TokenStorageUseCase = TokenStorageUseCase()
  public static var previewValue: TokenStorageUseCase = TokenStorageUseCase()
}

public extension DependencyValues {
  var tokenStorageUseCase: TokenStorageUseCase {
    get { self[TokenStorageUseCase.self] }
    set { self[TokenStorageUseCase.self] = newValue }
  }
}
