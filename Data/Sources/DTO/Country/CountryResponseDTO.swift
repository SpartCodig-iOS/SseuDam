//
//  CountryResponseDTO.swift
//  Data
//
//  Created by 김민희 on 11/27/25.
//

import Foundation

public struct CountryResponseDTO: Decodable {
    public let code: String
    public let nameKo: String
    public let nameEn: String
    public let currencies: [String]  
}
