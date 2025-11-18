//
//  Extension+UIImage.swift
//  DesignSystem
//
//  Created by Wonji Suh  on 11/18/25.
//

import SwiftUI
import UIKit

public extension UIImage {
  convenience init?(_ asset: ImageAsset) {
    self.init(named: asset.rawValue, in: Bundle.module, with: nil)
  }

  convenience init?(assetName: String) {
    self.init(named: assetName, in: Bundle.module, with: nil)
  }
}


// DSResources.swift
import Foundation

public enum DSResources {
  public static let bundle: Bundle = .module
}

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

#if canImport(UIKit)
public extension UIImage {
  /// 문자열 기반 에셋 이름
  convenience init?(assetName: String, in bundle: Bundle = DSResources.bundle) {
    self.init(named: assetName, in: bundle, with: nil)
  }

  convenience init?<Asset: RawRepresentable>(
    asset: Asset,
    in bundle: Bundle = DSResources.bundle
  ) where Asset.RawValue == String {
    self.init(named: asset.rawValue, in: bundle, with: nil)
  }
}
#endif


import SwiftUI

public extension Image {
  /// 문자열 기반 에셋 이름
  init(assetName: String, bundle: Bundle = DSResources.bundle) {
    self.init(assetName, bundle: bundle)
  }

  init<Asset: RawRepresentable>(
    asset: Asset,
    bundle: Bundle = DSResources.bundle
  ) where Asset.RawValue == String {
    self.init(asset.rawValue, bundle: bundle)
  }
}


