//
//  ProfileTarget.swift
//  Data
//
//  Created by Wonji Suh  on 12/1/25.
//

import Foundation
import Moya
import NetworkService

public enum ProfileTarget {
  case getProfile
  case editProfile(name: String?, image: Data?, fileName: String? = nil)
}


extension ProfileTarget: BaseTargetType {
  public typealias Domain = SseuDamDomain

   public var domain: SseuDamDomain {
    return .profile
  }

  public var urlPath: String {
    switch self {
      case .getProfile:
        return ProfileAPI.getProfile.description
      case .editProfile:
        return ProfileAPI.editProfile.description
    }
  }

  public var requiresAuthorization: Bool {
    return true
  }

  public var headers: [String: String]? {
    switch self {
    case .getProfile:
        return APIHeaders.accessTokenHeader
    case .editProfile:
      // multipart/form-data는 Alamofire가 boundary 포함해서 설정하므로 여기서는 유형만 지정
      var base = APIHeaders.accessTokenHeader
      base["Content-Type"] = "multipart/form-data"
      return base
    }
  }

  public var error: [Int : NetworkService.NetworkError]? {
    return nil
  }
  
  public var parameters: [String : Any]? {
    switch self {
      case .getProfile:
        return nil
      case .editProfile:
        return nil
    }
  }
  
  public var method: Moya.Method {
    switch self {
      case .getProfile:
        return .get
      case .editProfile:
        return .patch
    }
  }

  public var task: Moya.Task {
    switch self {
    case .getProfile:
      return .requestPlain

    case let .editProfile(name, image, fileName):
      var multipart: [MultipartFormData] = []

      if let name, let data = name.data(using: .utf8) {
        multipart.append(MultipartFormData(provider: .data(data), name: "name"))
      }

      if let image {
        let resolvedFileName = fileName ?? "avatar.jpg"
        multipart.append(
          MultipartFormData(
            provider: .data(image),
            name: "avatar",
            fileName: resolvedFileName,
            mimeType: "image/jpeg"
          )
        )
      }

      return .uploadMultipart(multipart)
    }
  }
}
