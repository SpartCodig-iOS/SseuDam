//
//  Typography.swift
//  DesignSystem
//
//  Created by 김민희 on 11/18/25.
//

import SwiftUI

public enum Typography {
    public static func resolve(style: AppFontStyle, weight: AppFontWeight) -> (size: CGFloat, weight: Font.Weight) {
        switch (style, weight) {
        // MARK: - Large Title (24)
        case (.largeTitle, .semibold): return (24, .semibold)
        case (.largeTitle, .medium):   return (24, .medium)
        case (.largeTitle, .regular):  return (24, .regular)

        // MARK: - Title1 (20)
        case (.title1, .semibold): return (20, .semibold)
        case (.title1, .medium):   return (20, .medium)
        case (.title1, .regular):  return (20, .regular)

        // MARK: - Title2 (18)
        case (.title2, .semibold): return (18, .semibold)
        case (.title2, .medium):   return (18, .medium)
        case (.title2, .regular):  return (18, .regular)

        // MARK: - Title3 (16)
        case (.title3, .semibold): return (16, .semibold)
        case (.title3, .medium):   return (16, .medium)
        case (.title3, .regular):  return (16, .regular)

        // MARK: - Body (14)
        case (.body, .semibold): return (14, .semibold)
        case (.body, .medium):   return (14, .medium)
        case (.body, .regular):  return (14, .regular)

        // MARK: - Caption1 (12)
        case (.caption1, .semibold): return (12, .semibold)
        case (.caption1, .medium):   return (12, .medium)
        case (.caption1, .regular):  return (12, .regular)

        // MARK: - Caption2 (10)
        case (.caption2, .semibold): return (10, .semibold)
        case (.caption2, .medium):   return (10, .medium)
        case (.caption2, .regular):  return (10, .regular)
        }
    }
}
