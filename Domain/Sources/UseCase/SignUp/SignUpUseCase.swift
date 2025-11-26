//
//  SignUpUseCase.swift
//  Domain
//
//  Created by Wonji Suh  on 11/26/25.
//

import ComposableArchitecture

public struct SignUpUseCase: SignUpUseCaseProtocol {
    
    private let repository: SignUpRepositoryProtocol
    
    public init(
        repository: SignUpRepositoryProtocol
    ) {
        self.repository = repository
    }
    
    
    public func checkUserSignUp(
        accessToken: String,
        socialType: SocialType
    ) async throws -> OAuthCheckUser {
        return try await repository.checkSignUpUser(input: OAuthCheckUserInput(accessToken: accessToken, socialType: socialType))
    }
}


// MARK: - Dependencies
extension SignUpUseCase: DependencyKey {
    public static var liveValue:  SignUpUseCaseProtocol =  {
        return SignUpUseCase(repository: MockSignUpRepository())
    } ()
    public static var previewValue:  SignUpUseCaseProtocol = liveValue
    public static var testValue:  SignUpUseCaseProtocol = SignUpUseCase(repository: MockSignUpRepository())
}

public extension DependencyValues {
    var signUpUseCase:  SignUpUseCaseProtocol {
        get { self[SignUpUseCase.self] }
        set { self[SignUpUseCase.self] = newValue }
    }
}
