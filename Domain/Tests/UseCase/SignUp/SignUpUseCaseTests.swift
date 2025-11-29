//
//  SignUpUseCaseTests.swift
//  Domain
//
//  Created by Wonji Suh on 12/05/24.
//

import Testing
import Foundation
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
            socialType: Domain.SocialType.google
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
            socialType: Domain.SocialType.apple
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
                socialType: Domain.SocialType.google
            )
        }
    }

    @Test("특정 provider 에러 시나리오")
    func testCheckUserSignUpProviderSpecificFailure() async throws {
        // Given
        let repository = MockSignUpRepository.failsForProvider(Domain.SocialType.apple)
        let useCase = SignUpUseCase(repository: repository)

        // When & Then
        await #expect(throws: MockSignUpRepositoryError.self) {
            _ = try await useCase.checkUserSignUp(
                accessToken: "apple-token",
                socialType: Domain.SocialType.apple
            )
        }
    }

    // MARK: - SignUpUser Tests

    @Test("Google 회원가입 성공")
    func testSignUpUserGoogleSuccess() async throws {
        // Given
        let repository = MockSignUpRepository()
        let useCase = SignUpUseCase(repository: repository)

        // When
        let result = try await useCase.signUp(
            accessToken: "google-access-token",
            socialType: Domain.SocialType.google,
            authCode: "google-auth-code"
        )

        // Then
        #expect(result.provider == Domain.SocialType.google)
        #expect(result.name.contains("MockUser_Google"))
        #expect(result.token.accessToken == "google-access-token")
    }

    @Test("Apple 회원가입 성공")
    func testSignUpUserAppleSuccess() async throws {
        // Given
        let repository = MockSignUpRepository()
        let useCase = SignUpUseCase(repository: repository)

        // When
        let result = try await useCase.signUp(
            accessToken: "apple-access-token",
            socialType: Domain.SocialType.apple,
            authCode: "apple-auth-code"
        )

        // Then
        #expect(result.provider == Domain.SocialType.apple)
        #expect(result.name.contains("MockUser_Apple"))
        #expect(result.token.accessToken == "apple-access-token")
    }

    @Test("회원가입 실패 시 에러 전달")
    func testSignUpUserFailure() async throws {
        // Given
        let repository = MockSignUpRepository.failure
        let useCase = SignUpUseCase(repository: repository)

        // When & Then
        await #expect(throws: MockSignUpRepositoryError.self) {
            _ = try await useCase.signUp(
                accessToken: "invalid-token",
                socialType: Domain.SocialType.google,
                authCode: "invalid-auth-code"
            )
        }
    }

    @Test("회원가입 특정 provider 에러 시나리오")
    func testSignUpUserProviderSpecificFailure() async throws {
        // Given
        let repository =  MockSignUpRepository.failsForProvider(Domain.SocialType.google)
        let useCase = SignUpUseCase(repository: repository)

        // When & Then
        await #expect(throws: MockSignUpRepositoryError.self) {
            _ = try await useCase.signUp(
                accessToken: "google-token",
                socialType: Domain.SocialType.google,
                authCode: "google-auth-code"
            )
        }
    }

    @Test("회원가입 지연 시간 테스트")
    func testSignUpUserWithDelay() async throws {
        // Given
        let repository = MockSignUpRepository.withDelay(1.0)
        let useCase = SignUpUseCase(repository: repository)
        let startTime = Date()

        // When
        let result = try await useCase.signUp(
            accessToken: "delayed-token",
            socialType: Domain.SocialType.apple,
            authCode: "delayed-auth-code"
        )

        // Then
        let elapsed = Date().timeIntervalSince(startTime)
        #expect(elapsed >= 1.0)
        #expect(result.provider == Domain.SocialType.apple)
    }
}
