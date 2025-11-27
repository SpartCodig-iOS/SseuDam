//
//  AppleLoginPayload.swift
//  Domain
//
//  Created by Wonji Suh  on 11/18/25.
//

import AuthenticationServices

public struct AppleLoginPayload: Equatable {
    public let credential: ASAuthorizationAppleIDCredential
    public let nonce: String
    
    public init(
        credential: ASAuthorizationAppleIDCredential,
        nonce: String
    ) {
        self.credential = credential
        self.nonce = nonce
    }
}


