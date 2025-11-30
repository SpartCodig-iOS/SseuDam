import Foundation
import SwiftUI

public extension ShapeStyle where Self == Color {
    // MARK: - Primary
    static var primary50: Color { asset(#function) }
    static var primary100: Color { asset(#function) }
    static var primary500: Color { asset(#function) }
    static var primary800: Color { asset(#function) }
    static var primary900: Color { asset(#function) }

    // MARK: - Gray
    static var gray1: Color { asset(#function) }
    static var gray2: Color { asset(#function) }
    static var gray5: Color { asset(#function) }
    static var gray7: Color { asset(#function) }
    static var gray8: Color { asset(#function) }

    // MARK: - Category Colors - Transportation
    static var transportation100: Color { asset(#function) }
    static var transportation500: Color { asset(#function) }

    // MARK: - Category Colors - Food
    static var food100: Color { asset(#function) }
    static var food500: Color { asset(#function) }

    // MARK: - Category Colors - Shopping
    static var shopping100: Color { asset(#function) }

    private static func asset(_ name: String) -> Color {
        Color(name, bundle: .module)
    }
}
