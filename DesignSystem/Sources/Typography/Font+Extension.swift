//
//  Font+Extension.swift
//  DesignSystem
//
//  Created by 김민희 on 11/18/25.
//

import SwiftUI

public extension Font {
    static func app(_ style: AppFontStyle, weight: AppFontWeight = .regular) -> Font {
        let config = Typography.resolve(style: style, weight: weight)
        return .system(size: config.size, weight: config.weight)
    }
}
