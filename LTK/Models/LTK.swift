//
//  LTK.swift
//  LTK
//
//  Created by Laura Artiles on 2/6/22.
//

import Foundation

struct APIResponse: Codable {
  let ltks: [LTK]
  let profiles: [Profile]
  let meta: Metadata
  let products: [Product]
}

struct LTK: Codable {
  let id: String
  let heroImage: String
  let heroImageWidth: Int
  let heroImageHeight: Int
  let profileId: String
  let productIds: [String]
  
  private enum CodingKeys: String, CodingKey {
    case id
    case heroImage = "hero_image"
    case heroImageWidth = "hero_image_width"
    case heroImageHeight = "hero_image_height"
    case profileId = "profile_id"
    case productIds = "product_ids"
  }
}
