//
//  OAuthUseCaseTests.swift
//  Domain
//
//  Created by Wonji Suh on 11/26/25.
//

import Testing
@testable import Domain

@Suite("OAuth UseCase Tests", .serialized, .tags(.unit, .useCase))
struct OAuthUseCaseTests {

    // MARK: - UseCase 기본 플로우

    @Test("Google 로그인 성공")
    func testGoogleSignUpReturnsMockUser() async throws {
        // Given
        let oAuthUseCase = OAuthUseCase(
            repository: MockOAuthRepository(),
            googleRepository: MockGoogleOAuthRepository(),
            appleRepository: MockAppleOAuthRepository(),
            kakaoRepository: MockKakaoOAuthRepository()
        )

        // When
        let result = try await oAuthUseCase.signUp(with: Domain.SocialType.google)

        // Then
        #expect(result.provider == Domain.SocialType.google)
        #expect(result.displayName == "Mock Google User")
        #expect(result.email == "google.user@gmail.com")
    }

    @Test("Apple 로그인 성공")
    func testAppleSignUpReturnsMockUser() async throws {
        // Given
        let oAuthUseCase = OAuthUseCase(
            repository: MockOAuthRepository(),
            googleRepository: MockGoogleOAuthRepository(),
            appleRepository: MockAppleOAuthRepository(),
            kakaoRepository: MockKakaoOAuthRepository()
        )

        // When
        let result = try await oAuthUseCase.signUp(with: Domain.SocialType.apple)

        // Then
        #expect(result.provider == Domain.SocialType.apple)
        #expect(result.displayName == "Mock Apple User")
        #expect(result.email == "apple.user@icloud.com")
    }

    // MARK: - Repository Actors

    @Test("Google Repository Actor 응답 검증")
    func testGoogleRepositoryActor() async throws {
        // Given
        let mockRepo = MockGoogleOAuthRepository()

        // When
        let result = try await mockRepo.signIn()

        // Then
        #expect(result.displayName == "Mock Google User")
        #expect(result.idToken.contains("mock.google.idtoken"))
        #expect(result.accessToken?.contains("ya29.mock-google-access-token") ?? false)
    }

    @Test("Kakao Repository Actor 응답 검증")
    func testKakaoRepositoryActor() async throws {
        // Given
        let mockRepo = MockKakaoOAuthRepository()

        // When
        let result = try await mockRepo.signIn()

        // Then
        #expect(result.displayName == "Mock Kakao User")
        #expect(result.idToken.contains("mock.kakao.idtoken"))
        #expect(result.accessToken.contains("mock-kakao-access-token"))
    }

    @Test("Apple Repository Actor 응답 검증")
    func testAppleRepositoryActor() async throws {
        // Given
        let mockRepo = MockAppleOAuthRepository()

        // When
        let result = try await mockRepo.signIn()

        // Then
        #expect(result.displayName == "Mock Apple User")
        #expect(result.idToken.contains("eyJhbGciOiJSUzI1NiIsImtpZCI6Im1vY2sta2lkIn0"))
        #expect(result.nonce.contains("mock-apple-nonce"))
    }

    @Test("SignUp Repository Actor 응답 검증")
    func testSignUpRepositoryActor() async throws {
        // Given
        let mockRepo = MockSignUpRepository()

        // When
        let result = try await mockRepo.checkSignUp(
            input: OAuthUserInput(
                accessToken: "test-token",
                socialType: Domain.SocialType.google,
                authorizationCode: "test-auth-code"
            )
        )

        // Then
        #expect(result.registered == true)
    }
}
