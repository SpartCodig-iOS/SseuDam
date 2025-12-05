//
//  SocialType.swift
//  Domain
//
//  Created by Wonji Suh  on 11/17/25.
//

import Foundation


public enum SocialType: String, CaseIterable, Identifiable, Hashable {
    case none
    case apple
    case google
    case kakao
    
    public var id: String { rawValue }
    
    var description: String {
        switch self {
            case .none:
                return "email"
            case .apple:
                return "Apple"
            case .google:
                return "Google"
            case .kakao:
                return "kakao"

        }
    }
    
    
    public var image: String {
        switch self {
            case .apple:
                return "apple.logo"
            case .google:
                return "google"
            case .kakao:
                return "kakao"
            case .none:
                return ""
        }
    }
}
