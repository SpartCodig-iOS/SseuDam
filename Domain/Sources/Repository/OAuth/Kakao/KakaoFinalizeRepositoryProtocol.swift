//
//  KakaoFinalizeRepositoryProtocol.swift
//  Domain
//
//  Created by Assistant on 12/5/25.
//

import Foundation

public protocol KakaoFinalizeRepositoryProtocol {
    func finalize(ticket: String) async throws -> AuthResult
}
