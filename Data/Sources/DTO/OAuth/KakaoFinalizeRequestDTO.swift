//
//  KakaoFinalizeRequestDTO.swift
//  Data
//
//  Created by Assistant on 12/5/25.
//

import Foundation

public struct KakaoFinalizeRequestDTO: Encodable {
    public let ticket: String
    
    public init(ticket: String) {
        self.ticket = ticket
    }
}
