//
//  AuthDeleteResponseDTO.swift
//  Data
//
//  Created by Wonji Suh  on 12/2/25.
//


import Foundation

public struct AuthDeleteResponseDTO: Decodable {
  let userID: String
  let supabaseDeleted: Bool
}
