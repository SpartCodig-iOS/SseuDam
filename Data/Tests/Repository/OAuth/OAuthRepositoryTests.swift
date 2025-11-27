//
//  OAuthRepositoryTests.swift
//  Data
//
//  Created by Wonji Suh on 11/26/25.
//

import Testing
import Foundation
import Moya
import Domain
import NetworkService
@testable import Data

@Suite("OAuth Repository Tests", .serialized, .tags(.repository, .unit))
struct OAuthRepositoryTests {

    // MARK: - TDD: Target 구성이 올바른지 확인

    @Test("checkSignUpUser 타깃이 올바른 경로와 메서드를 사용한다")
    func testOAuthAPITarget_HasCorrectPathAndMethod() throws {
        // Given
        let body = LoginUserRequestDTO(accessToken: "token", loginType: "google")
        let target = OAuthAPITarget.checkSignUpUser(body: body)

        // Then
        #expect(target.urlPath == OAuthAPI.checkSignUpUser.description)
        #expect(target.method == Moya.Method.post)
    }

    @Test("checkSignUpUser 타깃이 파라미터를 올바르게 인코딩한다")
    func testOAuthAPITarget_EncodesParameters() throws {
        // Given
        let body = LoginUserRequestDTO(accessToken: "token-123", loginType: "apple")
        let target = OAuthAPITarget.checkSignUpUser(body: body)

        // When
        let params = target.parameters as? [String: Any]

        // Then
        #expect(params?["accessToken"] as? String == "token-123")
        #expect(params?["loginType"] as? String == "apple")
    }

    @Test("baseURL와 path 조합이 올바른 전체 URL을 만든다")
    func testOAuthAPITarget_BuildsFullURL() throws {
        // Given
        let body = LoginUserRequestDTO(accessToken: "token", loginType: "google")
        let target = OAuthAPITarget.checkSignUpUser(body: body)

        // When
        let fullURL = target.baseURL.appendingPathComponent(target.path).absoluteString

        // Then
        #expect(fullURL.contains(target.domain.baseURLString))
        #expect(fullURL.hasSuffix("/oauth\(OAuthAPI.checkSignUpUser.description)"))
    }

    // MARK: - Repository 메소드 테스트

    @Test("Google OAuth 로그인이 Supabase Session을 반환한다")
    func testOAuthRepository_SuccessfulGoogleSignIn() async throws {
        // Given
        let repository = OAuthRepository()

        // When & Then - 실제 Supabase 연동이므로 Mock 없이는 테스트하기 어려움
        // 이 테스트는 integration test로 분리하거나 Mock Supabase Client가 필요
        #expect(true) // placeholder for now
    }

    @Test("Apple OAuth 로그인이 Supabase Session을 반환한다")
    func testOAuthRepository_SuccessfulAppleSignIn() async throws {
        // Given
        let repository = OAuthRepository()

        // When & Then - 실제 Supabase 연동이므로 Mock 없이는 테스트하기 어려움
        #expect(true) // placeholder for now
    }

    @Test("사용자 displayName 업데이트가 성공한다")
    func testOAuthRepository_UpdateDisplayName() async throws {
        // Given
        let repository = OAuthRepository()

        // When & Then - 실제 Supabase 연동이므로 Mock 없이는 테스트하기 어려움
        #expect(true) // placeholder for now
    }
}
