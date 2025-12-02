//
//  ProfileRepository.swift
//  Data
//
//  Created by Wonji Suh  on 12/1/25.
//

import Foundation
import Moya
import Domain
import NetworkService

final public class ProfileRepository: ProfileRepositoryProtocol {
    private let provider: MoyaProvider<ProfileTarget>
    
    public init(provider: MoyaProvider<ProfileTarget> = MoyaProvider<ProfileTarget>.authorized) {
        self.provider = provider
    }
    
    public func getProfile() async throws -> Domain.Profile {
        let response: BaseResponse<ProfileResponseDTO> = try await provider.request(.getProfile)
        guard let data = response.data else {
            throw NetworkError.noData
        }
        return data.toDomain()
    }
    
    public func editProfile(
        name: String?,
        avatarData: Data?,
        fileName: String? = nil
    ) async throws -> Domain.Profile {
        let response: BaseResponse<ProfileResponseDTO> = try await provider.request(
            .editProfile(name: name, image: avatarData, fileName: fileName)
        )
        guard let data = response.data else {
            throw NetworkError.noData
        }
        return data.toDomain()
    }
    
}
