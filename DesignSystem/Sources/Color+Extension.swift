import Foundation
import SwiftUI

public extension Color {
    static var primary800: Color { asset(#function) }
    static var primary900: Color { asset(#function) }
    static var primary50: Color {asset(#function) }
    static var primary500: Color {asset(#function) }

    private static func asset(_ name: String) -> Color {
        Color(name, bundle: .module)
    }
}
