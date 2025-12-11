//
//  AuthRepositoryTests.swift
//  Data
//
//  Created by Wonji Suh on 12/11/25.
//

import Foundation
import Testing
import Domain
@testable import Data

@Suite("AuthRepository 통합 테스트", .serialized, .tags(.repository, .unit))
struct AuthRepositoryTests {

    // MARK: - Refresh
    @Test("refresh 호출 시 토큰 결과를 반환한다")
    func testRefresh() async throws {
        let remote = StubAuthRemoteDataSource()
        let sut = AuthRepository(remote: remote)

        let result = try await sut.refresh(token: "refresh-token")

        #expect(result.token.accessToken == "new-access-token")
        #expect(result.token.refreshToken == "new-refresh-token")
        #expect(result.token.sessionID == "session-123")
    }

    // MARK: - Device Token
    @Test("registerDeviceToken 호출 시 pendingKey를 반환한다")
    func testRegisterDeviceToken() async throws {
        let remote = StubAuthRemoteDataSource()
        let sut = AuthRepository(remote: remote)

        let result = try await sut.registerDeviceToken(token: "device-token")

        #expect(result.deviceToken == "device-token")
        #expect(result.pendingKey == "pending-123")
    }

    // MARK: - Delegation equivalence
    @Test("checkUser는 remote로 위임된다")
    func testCheckUserDelegatesToRemote() async throws {
        let remote = StubAuthRemoteDataSource()
        let sut = AuthRepository(remote: remote)

        _ = try await sut.checkUser(input: OAuthUserInput(accessToken: "acc", socialType: .google, authorizationCode: "code"))
        let didCall = await remote.didCallCheckUser
        #expect(didCall == true)
    }

    @Test("login은 remote로 위임된다")
    func testLoginDelegatesToRemote() async throws {
        let remote = StubAuthRemoteDataSource()
        let sut = AuthRepository(remote: remote)

        _ = try await sut.login(input: OAuthUserInput(accessToken: "acc", socialType: .google, authorizationCode: "code"))
        let didCall = await remote.didCallLogin
        #expect(didCall == true)
    }

    @Test("signUp은 remote로 위임된다")
    func testSignUpDelegatesToRemote() async throws {
        let remote = StubAuthRemoteDataSource()
        let sut = AuthRepository(remote: remote)

        _ = try await sut.signUp(input: OAuthUserInput(accessToken: "acc", socialType: .google, authorizationCode: "code"))
        let didCall = await remote.didCallSignUp
        #expect(didCall == true)
    }

    @Test("finalizeKakao는 remote로 위임된다")
    func testFinalizeKakaoDelegates() async throws {
        let remote = StubAuthRemoteDataSource()
        let sut = AuthRepository(remote: remote)

        _ = try await sut.finalizeKakao(ticket: "ticket")
        let didCall = await remote.didCallFinalize
        #expect(didCall == true)
    }
}

// MARK: - Stub Remote DataSource
private actor StubAuthRemoteDataSource: AuthRemoteDataSourceProtocol {
    let checkUserResult: OAuthCheckUser
    let loginResult: AuthResult
    let signUpResult: AuthResult
    let finalizeResult: AuthResult
    let deviceTokenResult: DeviceToken
    let refreshResult: TokenResult
    let logoutResult: LogoutStatus = LogoutStatus(revoked: true)
    let deleteResult: AuthDeleteStatus = AuthDeleteStatus(isDeleted: true)

    var didCallCheckUser = false
    var didCallLogin = false
    var didCallSignUp = false
    var didCallFinalize = false

    init(
        checkUserResult: OAuthCheckUser = OAuthCheckUser(registered: true, needsTerms: false),
        loginResult: AuthResult = AuthResult(
            userId: "user",
            name: "name",
            provider: .google,
            token: AuthTokens(authToken: "", accessToken: "new-access-token", refreshToken: "new-refresh-token", sessionID: "session-123")
        ),
        signUpResult: AuthResult = AuthResult(
            userId: "signup-user",
            name: "signup",
            provider: .google,
            token: AuthTokens(authToken: "", accessToken: "signup-access", refreshToken: "signup-refresh", sessionID: "signup-session")
        ),
        finalizeResult: AuthResult = AuthResult(
            userId: "kakao-user",
            name: "kakao",
            provider: .kakao,
            token: AuthTokens(authToken: "", accessToken: "kakao-access", refreshToken: "kakao-refresh", sessionID: "kakao-session")
        ),
        deviceTokenResult: DeviceToken = DeviceToken(deviceToken: "device-token", pendingKey: "pending-123"),
        refreshResult: TokenResult = TokenResult(token: AuthTokens(authToken: "", accessToken: "new-access-token", refreshToken: "new-refresh-token", sessionID: "session-123"))
    ) {
        self.checkUserResult = checkUserResult
        self.loginResult = loginResult
        self.signUpResult = signUpResult
        self.finalizeResult = finalizeResult
        self.deviceTokenResult = deviceTokenResult
        self.refreshResult = refreshResult
    }

    func refresh(token: String) async throws -> TokenResult { refreshResult }
    func logout(sessionId: String) async throws -> LogoutStatus { logoutResult }
    func delete() async throws -> AuthDeleteStatus { deleteResult }
    func registerDeviceToken(token: String) async throws -> DeviceToken { deviceTokenResult }
    func checkUser(input: OAuthUserInput) async throws -> OAuthCheckUser { didCallCheckUser = true; return checkUserResult }
    func login(input: OAuthUserInput) async throws -> AuthResult { didCallLogin = true; return loginResult }
    func signUp(input: OAuthUserInput) async throws -> AuthResult { didCallSignUp = true; return signUpResult }
    func finalizeKakao(ticket: String) async throws -> AuthResult { didCallFinalize = true; return finalizeResult }
}
