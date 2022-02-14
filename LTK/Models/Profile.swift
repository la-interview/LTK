//
//  Profile.swift
//  LTK
//
//  Created by Laura Artiles on 2/6/22.
//

import Foundation

struct Profile: Codable {
  let id: String
  let avatarUrl: String
  
  private enum CodingKeys: String, CodingKey {
    case id
    case avatarUrl = "avatar_url"
  }
}
