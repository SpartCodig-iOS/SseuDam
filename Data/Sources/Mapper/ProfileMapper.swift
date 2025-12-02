//
//  ProfileMapper.swift
//  Data
//
//  Created by Wonji Suh  on 12/1/25.
//

import Domain

extension ProfileResponseDTO {
  func toDomain() -> Profile {
    
    let socialType = SocialType(rawValue: self.loginType ?? "") ?? .none

    return Profile(
      userId: self.userID,
      email: self.email,
      name: self.name,
      profileImage: self.avatarURL,
      provider: socialType
    )
  }
}
