//
//  LoginUseCaseTests.swift
//  Domain
//
//  Created by Wonji Suh on 11/26/25.
//

import Testing
import Foundation
@testable import Domain
import Dependencies

@Suite("Login UseCase Tests", .serialized, .tags(.unit, .useCase))
struct LoginUseCaseTests {

    // MARK: - Basic Login Flow Tests

    @Test("Google 로그인 성공")
    func testLoginUserGoogleSuccess() async throws {
        // Given
        let mockRepository = MockLoginRepository.googleUser
        let useCase = LoginUseCase(repository: mockRepository)

        // When
        let result = try await useCase.login(
            accessToken: "google-access-token",
            socialType: Domain.SocialType.google
        )

        // Then
        #expect(result.provider == Domain.SocialType.google)
        #expect(result.name == "Google User")
        #expect(result.token.accessToken == "google-access-token")
    }

    @Test("Apple 로그인 성공")
    func testLoginUserAppleSuccess() async throws {
        // Given
        let mockRepository = MockLoginRepository.appleUser
        let useCase = LoginUseCase(repository: mockRepository)

        // When
        let result = try await useCase.login(
            accessToken: "apple-access-token",
            socialType: Domain.SocialType.apple
        )

        // Then
        #expect(result.provider == Domain.SocialType.apple)
        #expect(result.name == "Apple User")
        #expect(result.token.accessToken == "apple-access-token")
    }

    @Test("로그인 실패 시 에러 전달")
    func testLoginUserFailure() async throws {
        // Given
        let mockRepository = MockLoginRepository.failure
        let useCase = LoginUseCase(repository: mockRepository)

        // When & Then
        await #expect(throws: MockLoginRepositoryError.self) {
            _ = try await useCase.login(
                accessToken: "invalid-token",
                socialType: Domain.SocialType.google
            )
        }
    }

    @Test("특정 provider 실패 시나리오")
    func testLoginUserProviderSpecificFailure() async throws {
        // Given
        let mockRepository = MockLoginRepository.failsForProvider(Domain.SocialType.apple)
        let useCase = LoginUseCase(repository: mockRepository)

        // When & Then
        await #expect(throws: MockLoginRepositoryError.self) {
            _ = try await useCase.login(
                accessToken: "apple-token",
                socialType: Domain.SocialType.apple
            )
        }
    }

    @Test("로그인 지연 시간 테스트")
    func testLoginUserWithDelay() async throws {
        // Given
        let mockRepository = MockLoginRepository.withDelay(1.0)
        let useCase = LoginUseCase(repository: mockRepository)
        let startTime = Date()

        // When
        let result = try await useCase.login(
            accessToken: "delayed-token",
            socialType: Domain.SocialType.google
        )

        // Then
        let elapsed = Date().timeIntervalSince(startTime)
        #expect(elapsed >= 1.0)
        #expect(result.provider == Domain.SocialType.google)
    }

    @Test("커스텀 사용자 로그인 테스트")
    func testLoginUserWithCustomUser() async throws {
        // Given
        let mockRepository = MockLoginRepository.withCustomUser(
            name: "Custom Test User",
            provider: Domain.SocialType.apple
        )
        let useCase = LoginUseCase(repository: mockRepository)

        // When
        let result = try await useCase.login(
            accessToken: "custom-access-token",
            socialType: Domain.SocialType.apple
        )

        // Then
        #expect(result.provider == Domain.SocialType.apple)
        #expect(result.name == "Custom Test User")
        #expect(result.token.accessToken == "custom-access-token")
    }

    // MARK: - Dependencies Tests

    @Test("Dependencies를 통한 UseCase 생성 테스트")
    func testUseCaseCreationThroughDependencies() async throws {
        let mockRepository = MockLoginRepository.googleUser
        let result = try await withDependencies {
            $0.loginUseCase = LoginUseCase(repository: mockRepository)
        } operation: {
            try await LoginUseCaseDependencyConsumer()
                .run(accessToken: "dep-token", socialType: .google)
        }

        #expect(result.provider == .google)
        #expect(result.token.accessToken == "dep-token")
    }
}

// MARK: - Extensions for accessing private methods

private extension LoginUseCase {
    static func mockedDependency() -> LoginUseCase {
        let repo = MockLoginRepository()
        return LoginUseCase(repository: repo)
    }
}

private struct LoginUseCaseDependencyConsumer {
    @Dependency(\.loginUseCase) var loginUseCase

    func run(accessToken: String, socialType: SocialType) async throws -> AuthResult {
        try await loginUseCase.login(accessToken: accessToken, socialType: socialType)
    }
}
