//
//  PretendardFont.swift
//  DesignSystem
//
//  Created by Wonji Suh  on 11/18/25.
//

import SwiftUI

struct PretendardFont: ViewModifier {
  public let family: PretendardFontFamily
  public let size: CGFloat

  public func body(content: Content) -> some View {
    return content.font(.custom("PretendardVariable-\(family)", fixedSize: size))
  }
}

 extension Font {
  static func pretendardFont(family: PretendardFontFamily, size: CGFloat) -> Font{
    let font = Font.custom("PretendardVariable-\(family)", size: size)
    return font
  }
}
