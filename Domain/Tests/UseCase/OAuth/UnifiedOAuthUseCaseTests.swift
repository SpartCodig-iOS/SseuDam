//
//  UnifiedOAuthUseCaseTests.swift
//  Domain
//
//  Created by Wonji Suh on 12/11/25.
//

import Testing
@testable import Domain

struct UnifiedOAuthUseCaseTests {

    // MARK: - Helpers
    private func makeAuthData() -> AuthData {
        AuthData(
            socialType: .google,
            accessToken: "access-token",
            authToken: "auth-token",
            displayName: "Tester",
            authorizationCode: "auth-code",
            codeVerifier: nil,
            redirectUri: nil,
            refreshToken: "refresh-token",
            sessionID: "session-id",
            userId: "user-id"
        )
    }

    // MARK: - Tests

    @Test("등록된 사용자 로그인 시 토큰이 저장된다")
    func testLoginSavesTokens() async throws {
        // Given
        let authData = makeAuthData()
        let authRepository = StubAuthRepository(
            checkUserResult: OAuthCheckUser(registered: true, needsTerms: false),
            loginResult: AuthResult(
                userId: "user-id",
                name: "Tester",
                provider: .google,
                token: AuthTokens(
                    authToken: "",
                    accessToken: "login-access",
                    refreshToken: "login-refresh",
                    sessionID: "login-session"
                )
            )
        )
        let sessionStore = MockSessionStoreRepository()

        let sut = UnifiedOAuthUseCase(
            oAuthUseCase: OAuthUseCase.testValue,
            authRepository: authRepository,
            sessionStoreRepository: sessionStore
        )

        // When
        let result = await sut.loginUser(with: authData)

        // Then
        guard case .success = result else {
            Issue.record("loginUser should succeed")
            return
        }
        #expect(sessionStore.savedTokens?.accessToken == "login-access")
        #expect(sessionStore.savedTokens?.refreshToken == "login-refresh")
        #expect(sessionStore.savedTokens?.sessionID == "login-session")
    }

    @Test("신규 사용자 회원가입 시 토큰이 저장된다")
    func testSignUpSavesTokens() async throws {
        // Given
        let authData = makeAuthData()
        let authRepository = StubAuthRepository(
            checkUserResult: OAuthCheckUser(registered: false, needsTerms: false),
            signUpResult: AuthResult(
                userId: "new-user-id",
                name: "New User",
                provider: .google,
                token: AuthTokens(
                    authToken: "",
                    accessToken: "signup-access",
                    refreshToken: "signup-refresh",
                    sessionID: "signup-session"
                )
            )
        )
        let sessionStore = MockSessionStoreRepository()

        let sut = UnifiedOAuthUseCase(
            oAuthUseCase: OAuthUseCase.testValue,
            authRepository: authRepository,
            sessionStoreRepository: sessionStore
        )

        // When
        let result = await sut.signUpUser(with: authData)

        // Then
        guard case .success = result else {
            Issue.record("signUpUser should succeed")
            return
        }
        #expect(sessionStore.savedTokens?.accessToken == "signup-access")
        #expect(sessionStore.savedTokens?.refreshToken == "signup-refresh")
        #expect(sessionStore.savedTokens?.sessionID == "signup-session")
    }

    @Test("가입 여부 확인에서 needsTerms 응답을 반환할 수 있다")
    func testCheckUserReturnsNeedsTerms() async throws {
        // Given
        let authData = makeAuthData()
        let authRepository = StubAuthRepository(
            checkUserResult: OAuthCheckUser(registered: false, needsTerms: true)
        )

        let sut = UnifiedOAuthUseCase(
            oAuthUseCase: OAuthUseCase.testValue,
            authRepository: authRepository,
            sessionStoreRepository: MockSessionStoreRepository()
        )

        // When
        let result = await sut.checkSignUpUser(with: authData)

        // Then
        guard case .success(let checkUser) = result else {
            Issue.record("checkUser should succeed")
            return
        }
        #expect(checkUser.registered == false)
        #expect(checkUser.needsTerms == true)
    }
}

// MARK: - Mock Session Store
private final class MockSessionStoreRepository: SessionStoreRepositoryProtocol, @unchecked Sendable {
    var savedTokens: AuthTokens?
    var savedSocialType: SocialType?
    var savedUserId: String?

    func save(tokens: AuthTokens, socialType: SocialType?, userId: String?) async {
        savedTokens = tokens
        savedSocialType = socialType
        savedUserId = userId
    }

    func loadTokens() async -> AuthTokens? { savedTokens }
    func loadSocialType() async -> SocialType? { savedSocialType }
    func loadUserId() async -> String? { savedUserId }
    func clearAll() async {
        savedTokens = nil
        savedSocialType = nil
        savedUserId = nil
    }
}

// MARK: - Stub Auth Repository
private final class StubAuthRepository: AuthRepositoryProtocol {
    var checkUserResult: OAuthCheckUser
    var loginResult: AuthResult
    var signUpResult: AuthResult
    var finalizeResult: AuthResult

    init(
        checkUserResult: OAuthCheckUser = OAuthCheckUser(registered: true, needsTerms: false),
        loginResult: AuthResult = AuthResult(
            userId: "user",
            name: "name",
            provider: .google,
            token: AuthTokens(authToken: "", accessToken: "acc", refreshToken: "ref", sessionID: "session")
        ),
        signUpResult: AuthResult = AuthResult(
            userId: "signup-user",
            name: "signup",
            provider: .google,
            token: AuthTokens(authToken: "", accessToken: "acc", refreshToken: "ref", sessionID: "session")
        ),
        finalizeResult: AuthResult = AuthResult(
            userId: "kakao-user",
            name: "kakao",
            provider: .kakao,
            token: AuthTokens(authToken: "", accessToken: "kakao-acc", refreshToken: "kakao-ref", sessionID: "kakao-session")
        )
    ) {
        self.checkUserResult = checkUserResult
        self.loginResult = loginResult
        self.signUpResult = signUpResult
        self.finalizeResult = finalizeResult
    }

    func checkUser(input: OAuthUserInput) async throws -> OAuthCheckUser { checkUserResult }
    func login(input: OAuthUserInput) async throws -> AuthResult { loginResult }
    func signUp(input: OAuthUserInput) async throws -> AuthResult { signUpResult }
    func finalizeKakao(ticket: String) async throws -> AuthResult { finalizeResult }
    func refresh(token: String) async throws -> TokenResult { TokenResult(token: AuthTokens(authToken: "", accessToken: "acc", refreshToken: "ref", sessionID: "session")) }
    func logout(sessionId: String) async throws -> LogoutStatus { LogoutStatus(revoked: true) }
    func delete() async throws -> AuthDeleteStatus { AuthDeleteStatus(isDeleted: true) }
    func registerDeviceToken(token: String) async throws -> DeviceToken { DeviceToken(deviceToken: token, pendingKey: nil) }
}
