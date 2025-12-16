//
//  KakaoOAuthRepositoryProtocol.swift
//  Domain
//
//  Created by Assistant on 12/4/25.
//

import Foundation
import Dependencies

public protocol KakaoOAuthRepositoryProtocol {
    func signIn() async throws -> KakaoOAuthPayload
}

// MARK: - Dependencies
public struct KakaoOAuthRepositoryDependencyKey: DependencyKey {
    public static var liveValue: KakaoOAuthRepositoryProtocol {
        fatalError("KakaoOAuthRepositoryDependency liveValue not implemented")
    } 
    public static var previewValue: KakaoOAuthRepositoryProtocol = MockKakaoOAuthRepository()
    public static var testValue: KakaoOAuthRepositoryProtocol = MockKakaoOAuthRepository()
}

public extension DependencyValues {
    var kakaoOAuthRepository: KakaoOAuthRepositoryProtocol {
        get { self[KakaoOAuthRepositoryDependencyKey.self] }
        set { self[KakaoOAuthRepositoryDependencyKey.self] = newValue }
    }
}