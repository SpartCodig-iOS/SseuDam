//
//  ExpenseCategory.swift
//  Domain
//
//  Created by 홍석현 on 11/17/25.
//

import Foundation

public enum ExpenseCategory: String, CaseIterable, Codable {
    case accommodation = "accommodation"    // 숙박
    case foodAndDrink  = "food_and_drink"   // 식비
    case transportation = "transportation"  // 교통
    case activity      = "activity"         // 관광/활동
    case shopping      = "shopping"         // 쇼핑/선물
    case other         = "other"            // 기타 지출
    
    // MARK: - 사용자 표시 (한국어 명칭)
    public var displayName: String {
        switch self {
        case .accommodation:
            return "숙박"
        case .foodAndDrink:
            return "식비"
        case .transportation:
            return "교통"
        case .activity:
            return "관광"
        case .shopping:
            return "쇼핑"
        case .other:
            return "기타"
        }
    }
}
