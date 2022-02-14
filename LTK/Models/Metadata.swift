//
//  Metadata.swift
//  LTK
//
//  Created by Laura Artiles on 2/6/22.
//

import Foundation

struct Metadata: Codable {
  let lastId: String
  let numResults: Int
  let totalResults: Int
  let limit: Int
  let seed: String
  let nextUrl: String?
  
  private enum CodingKeys: String, CodingKey {
    case lastId = "last_id"
    case numResults = "num_results"
    case totalResults = "total_results"
    case limit
    case seed
    case nextUrl = "next_url"
  }
}
