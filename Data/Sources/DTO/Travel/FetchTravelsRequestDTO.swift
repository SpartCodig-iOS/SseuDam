//
//  FetchTravelsRequestDTO.swift
//  Data
//
//  Created by 김민희 on 11/19/25.
//

import Foundation

public struct FetchTravelsRequestDTO: Encodable {
    let limit: Int
    let page: Int
}
