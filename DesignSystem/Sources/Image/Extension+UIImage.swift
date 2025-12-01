//
//  Extension+UIImage.swift
//  DesignSystem
//
//  Created by Wonji Suh  on 11/18/25.
//

import SwiftUI

public extension Bundle {
  /// 외부 모듈에서도 사용할 수 있도록 공개 번들 헬퍼
  static var designSystem: Bundle { .module }
}

public extension Image {
  /// 문자열 기반 에셋 이름을 SwiftUI Image로 로드
  init(assetName: String, bundle: Bundle = .designSystem) {
    self.init(assetName, bundle: bundle)
  }

  /// ImageAsset을 사용해 에셋을 로드 (축약 문법 지원)
  init(asset: ImageAsset, bundle: Bundle = .designSystem) {
    self.init(asset.rawValue, bundle: bundle)
  }

  /// RawValue가 String인 enum 등을 사용해 에셋을 로드
  init<Asset: RawRepresentable>(
    asset: Asset,
    bundle: Bundle = .designSystem
  ) where Asset.RawValue == String {
    self.init(asset.rawValue, bundle: bundle)
  }
}
