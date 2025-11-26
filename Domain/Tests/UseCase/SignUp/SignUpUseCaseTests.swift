//
//  SignUpUseCaseTests.swift
//  Domain
//
//  Created by Wonji Suh on 12/05/24.
//

import Testing
@testable import Domain

@Suite("SignUp UseCase Tests", .serialized, .tags(.unit, .useCase))
struct SignUpUseCaseTests {

    // MARK: - Tests

    @Test("기존 사용자 등록 여부 확인 (등록됨)")
    func testCheckUserSignUpRegisteredUser() async throws {
        // Given
        let repository = MockSignUpRepository.registeredUser
        let useCase = SignUpUseCase(repository: repository)

        // When
        let result = try await useCase.checkUserSignUp(
            accessToken: "registered-token",
            socialType: .google
        )

        // Then
        #expect(result.registered == true)
    }

    @Test("기존 사용자 등록 여부 확인 (신규 사용자)")
    func testCheckUserSignUpNewUser() async throws {
        // Given
        let repository = MockSignUpRepository.newUser
        let useCase = SignUpUseCase(repository: repository)

        // When
        let result = try await useCase.checkUserSignUp(
            accessToken: "new-user-token",
            socialType: .apple
        )

        // Then
        #expect(result.registered == false)
    }

    @Test("등록 확인 실패 시 에러 전달")
    func testCheckUserSignUpFailure() async throws {
        // Given
        let repository = MockSignUpRepository.failure
        let useCase = SignUpUseCase(repository: repository)

        // When & Then
        await #expect(throws: MockSignUpRepositoryError.self) {
            _ = try await useCase.checkUserSignUp(
                accessToken: "invalid-token",
                socialType: .google
            )
        }
    }

    @Test("특정 provider 에러 시나리오")
    func testCheckUserSignUpProviderSpecificFailure() async throws {
        // Given
        let repository = MockSignUpRepository.failsForProvider(.apple)
        let useCase = SignUpUseCase(repository: repository)

        // When & Then
        await #expect(throws: MockSignUpRepositoryError.self) {
            _ = try await useCase.checkUserSignUp(
                accessToken: "apple-token",
                socialType: .apple
            )
        }
    }
}
