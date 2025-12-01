//
//  ToastType.swift
//  DesignSystem
//
//  Created by Wonji Suh on 11/28/25.
//

import SwiftUI

public enum ToastType: Equatable {
    case success(String)
    case error(String)
    case warning(String)
    case info(String)

    public var message: String {
        switch self {
        case .success(let message),
             .error(let message),
             .warning(let message),
             .info(let message):
            return message
        }
    }

    public var backgroundColor: Color {
        switch self {
        case .success:
            return .gray5
        case .error:
            return .gray5
        case .warning:
            return .gray5
        case .info:
            return .gray5
        }
    }

    public var iconName: String {
        switch self {
        case .success:
            return "checkmark.circle.fill"
        case .error:
            return "xmark"
        case .warning:
            return "xmark"
        case .info:
            return "info.circle.fill"
        }
    }
}
