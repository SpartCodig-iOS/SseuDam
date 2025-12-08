//
//  SupabaseUserMapper.swift
//  Data
//
//  Created by Wonji Suh on 11/28/25.
//

import Domain
import Supabase

extension Supabase.Session {
    func toDomain(authorizationCode: String?) -> UserProfile {
        UserProfile(
            id: user.id.uuidString,
            email: user.email,
            displayName: user.displayNameValue,
            provider: user.providerType,
            tokens: AuthTokens(
                authToken: accessToken,
                accessToken: "",
                refreshToken: "",
                sessionID: ""
            ),
            authCode: authorizationCode
        )
    }
}

extension SocialType {
    /// Supabase OpenID provider (카카오는 미지원이라 fallback 사용)
    var openIDProvider: OpenIDConnectCredentials.Provider {
        switch self {
        case .google: return .google
        case .apple: return .apple
        case .kakao: return .google // Kakao는 별도 authProvider 사용
        case .none: return .google
        }
    }

    /// Supabase Auth provider (OAuth/OIDC)
    var authProvider: Provider {
        switch self {
        case .google: return .google
        case .apple: return .apple
        case .kakao: return .kakao
        case .none: return .google
        }
    }
}

private extension Supabase.User {
    var providerType: SocialType {
        SocialType(rawValue: providerString ?? "") ?? .none
    }

    var providerString: String? {
        if let provider = appMetadata["provider"]?.stringValue {
            return provider
        }

        if let providers = appMetadata["providers"]?.arrayValue,
           let first = providers.first?.stringValue {
            return first
        }
        return nil
    }

    var displayNameValue: String? {
        if let name = userMetadata["display_name"]?.stringValue, !name.isEmpty {
            return name
        }
        if let name = userMetadata["full_name"]?.stringValue, !name.isEmpty {
            return name
        }
        if let name = userMetadata["name"]?.stringValue, !name.isEmpty {
            return name
        }
        return nil
    }
}

private extension AnyJSON {
    var stringValue: String? {
        if case let .string(value) = self {
            return value
        }
        return nil
    }

    var arrayValue: [AnyJSON]? {
        if case let .array(value) = self {
            return value
        }
        return nil
    }
}
