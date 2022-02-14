//
//  Product.swift
//  LTK
//
//  Created by Laura Artiles on 2/6/22.
//

import Foundation

struct Product: Codable {
  let id: String
  let imageUrl: String
  let hyperlink: String
  
  private enum CodingKeys: String, CodingKey {
    case id
    case imageUrl = "image_url"
    case hyperlink
  }
}
