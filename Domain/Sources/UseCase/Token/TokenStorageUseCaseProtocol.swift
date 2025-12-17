//
//  TokenStorageUseCaseProtocol.swift
//  Domain
//
//  Created by Wonji Suh  on 12/17/25.
//

import Foundation

public protocol TokenStorageUseCaseProtocol {
    func save(auth: AuthResult) async
}
