//
//  TravelMemberDTO.swift
//  Data
//
//  Created by 김민희 on 11/17/25.
//

import Foundation
import Domain

struct TravelMemberDTO: Decodable {
    let userId: String
    let name: String
    let role: String
}
