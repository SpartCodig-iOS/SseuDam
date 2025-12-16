//
//  CurrencyFormatter.swift
//  Domain
//
//  Created by 홍석현 on 12/15/25.
//

import Foundation

public enum CurrencyFormatter {
    /// 한국식 통화 포맷 (억/만/원 단위)
    public static func formatKoreanCurrency(_ amount: Double) -> String {
        let rounded = amount.rounded()

        // Double로 계산하고 포맷팅
        let eokDouble = (rounded / 100_000_000).rounded(.towardZero)  // 억
        let remainder1 = rounded.truncatingRemainder(dividingBy: 100_000_000)
        let manDouble = (remainder1 / 10_000).rounded(.towardZero)  // 만
        let wonDouble = remainder1.truncatingRemainder(dividingBy: 10_000)  // 원

        var result = ""

        if eokDouble > 0 {
            result += "\(eokDouble.formatted(.number.precision(.fractionLength(0))))억"
            if manDouble > 0 {
                result += " \(manDouble.formatted(.number.precision(.fractionLength(0))))만"
            }
            if wonDouble > 0 {
                result += " \(wonDouble.formatted(.number.precision(.fractionLength(0))))원"
            }
        } else if manDouble > 0 {
            result += "\(manDouble.formatted(.number.precision(.fractionLength(0))))만"
            if wonDouble > 0 {
                result += " \(wonDouble.formatted(.number.precision(.fractionLength(0))))원"
            }
        } else {
            result = "\(wonDouble.formatted(.number.precision(.fractionLength(0))))원"
        }

        return result
    }
}
