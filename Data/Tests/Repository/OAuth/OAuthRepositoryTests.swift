//
//  OAuthRepositoryTests.swift
//  Data
//
//  Created by Wonji Suh on 11/26/25.
//

import Testing
import Foundation
import Moya
@testable import Data

@Suite("OAuth Repository Tests", .serialized, .tags(.repository, .unit))
struct OAuthRepositoryTests {

    // MARK: - TDD: Target 구성이 올바른지 확인

    @Test("checkSignUpUser 타깃이 올바른 경로와 메서드를 사용한다")
    func testOAuthAPITarget_HasCorrectPathAndMethod() throws {
        // Given
        let body = OAuthCheckUserRequestDTO(accessToken: "token", loginType: "google")
        let target = OAuthAPITarget.checkSignUpUser(body: body)

        // Then
        #expect(target.urlPath == OAuthAPI.checkSignUpUser.description)
        #expect(target.method == .post)
    }

    @Test("checkSignUpUser 타깃이 파라미터를 올바르게 인코딩한다")
    func testOAuthAPITarget_EncodesParameters() throws {
        // Given
        let body = OAuthCheckUserRequestDTO(accessToken: "token-123", loginType: "apple")
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
        let body = OAuthCheckUserRequestDTO(accessToken: "token", loginType: "google")
        let target = OAuthAPITarget.checkSignUpUser(body: body)

        // When
        let fullURL = target.baseURL.appendingPathComponent(target.path).absoluteString

        // Then
        #expect(fullURL.contains(target.domain.baseURLString))
        #expect(fullURL.hasSuffix("/oauth\(OAuthAPI.checkSignUpUser.description)"))
    }
}
