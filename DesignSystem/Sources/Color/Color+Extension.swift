import Foundation
import SwiftUI

public extension Color {
    static var white: Color { asset(#function) }
    static var black: Color { asset(#function) }

    //MARK: - primary
    static var primary50: Color { asset(#function) }
    static var primary100: Color { asset(#function) }
    static var primary200: Color { asset(#function) }
    static var primary300: Color { asset(#function) }
    static var primary400: Color { asset(#function) }
    static var primary500: Color { asset(#function) }
    static var primary600: Color { asset(#function) }
    static var primary700: Color { asset(#function) }
    static var primary800: Color { asset(#function) }
    static var primary900: Color { asset(#function) }

    //MARK: - gray
    static var gray1: Color { asset(#function) }
    static var gray2: Color { asset(#function) }
    static var gray3: Color { asset(#function) }
    static var gray4: Color { asset(#function) }
    static var gray5: Color { asset(#function) }
    static var gray6: Color { asset(#function) }
    static var gray7: Color { asset(#function) }
    static var gray8: Color { asset(#function) }
    static var gray9: Color { asset(#function) }

    private static func asset(_ name: String) -> Color {
        Color(name, bundle: .module)
    }
}
