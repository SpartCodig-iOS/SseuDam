//
//  MyTravelMember.swift
//  Domain
//
//  Created by 김민희 on 12/10/25.
//

import Foundation

public struct MyTravelMember {
    public let myInfo: TravelMember
    public let memberInfo: [TravelMember]

    public init(
        myInfo: TravelMember,
        memberInfo: [TravelMember]
    ) {
        self.myInfo = myInfo
        self.memberInfo = memberInfo
    }
}
