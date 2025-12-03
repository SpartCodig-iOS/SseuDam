//
//  FetchTravelsRequestDTO.swift
//  Data
//
//  Created by 김민희 on 11/19/25.
//

import Foundation
import Domain

public struct FetchTravelsRequestDTO: Encodable {
    let limit: Int
    let page: Int
    let status: String
}

extension FetchTravelsInput {
    func toDTO() -> FetchTravelsRequestDTO {
        FetchTravelsRequestDTO(
            limit: limit,
            page: page,
            status: status?.rawValue ?? "active"
        )
    }
}
