//
//  ContentService.swift
//  LTK
//
//  Created by Laura Artiles on 2/5/22.
//

import Foundation
import RxSwift

protocol ContentService {
  func getLtks(url: String?) -> Single<([LTK], Metadata)>
  func getProfile(for profileId: String) -> Single<Profile?>
  func getProducts(for productIds: [String]) -> Single<[Product]>
}

enum ContentServiceError: Error {
  case invalidUrl
  case decoding(error: Error)
  
  var reason: String {
    switch self {
    case .invalidUrl:
      return "Could not construct URL to fetch data"
    case .decoding:
      return "An error occurred while decoding data"
    }
  }
}

class LTKContentService: ContentService {
  private var cachedResponse: APIResponse?
  static let apiUrl = "https://api-gateway.rewardstyle.com/api/ltk/v2/ltks/?featured=true&limit=20"
  
  func getLtks(url: String?) -> Single<([LTK], Metadata)> {
    guard let url = url else {
      return .error(ContentServiceError.invalidUrl)
    }

    return makeAPIRequest(url: url)
      .map { ($0.ltks, $0.meta) }
  }
  
  func getProfile(for profileId: String) -> Single<Profile?> {
    // If we can find the profile in our cached response, just return that
    if let profile = cachedResponse?.profiles.first(where: { $0.id == profileId }) {
      return .just(profile)
    }
    // Otherwise try to make a new request
    let profile = makeAPIRequest()
      .map { $0.profiles.first(where: { $0.id == profileId }) }
    return profile
  }
  
  func getProducts(for productIds: [String]) -> Single<[Product]> {
    if let cachedResponse = cachedResponse {
      let products = cachedResponse.products.filter { productIds.contains($0.id) }
      return .just(products)
    }
    
    let products = makeAPIRequest()
      .map { $0.products.filter { productIds.contains($0.id) }}
    return products
    
  }
  
  private func makeAPIRequest(url: String? = nil) -> Single<APIResponse> {
    guard let url = URL(string: url ?? LTKContentService.apiUrl) else {
      return .error(ContentServiceError.invalidUrl)
    }
    
    return Single<APIResponse>.create { single in
      let task = URLSession.shared.dataTask(with: url) { data, response, error in
        if let error = error { single(.failure(error)) }
        guard let data = data else { return }
        
        do {
          let object = try JSONDecoder().decode(APIResponse.self, from: data)
          single(.success(object))
        }
        catch let error {
          single(.failure(ContentServiceError.decoding(error: error)))
        }
      }
      task.resume()
      return Disposables.create()
    }
    .do(onSuccess: { [weak self] response in
      self?.cachedResponse = response
    })
  }
}
