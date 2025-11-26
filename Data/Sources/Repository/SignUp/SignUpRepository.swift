//
//  SignUpRepository.swift
//  Data
//
//  Created by Wonji Suh  on 11/26/25.
//

import Foundation
import Domain

final public class SignUpRepository: SignUpRepositoryProtocol {
    private let dataSource: OAuthRemoteDataSourceProtocol
    
    public init(
        dataSource: OAuthRemoteDataSourceProtocol
    ) {
        self.dataSource = dataSource
    }
    
    public func checkSignUpUser(
        input: Domain.OAuthCheckUserInput
    ) async throws -> Domain.OAuthCheckUser {
        let body = OAuthCheckUserRequestDTO(accessToken: input.accessToken, loginType: input.socialType.rawValue)
        let data = try await dataSource.checkSingUpUser(body: body)
        return data.toDomain()
    }
    
}
