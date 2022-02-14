//
//  DetailsViewModel.swift
//  LTK
//
//  Created by Laura Artiles on 2/6/22.
//

import UIKit
import RxCocoa
import RxSwift

struct DetailsViewModelDependencies {
  let heroImage: String
  let heroImageAspectRatio: CGFloat
  let profileId: String
  let productIds: [String]
}

class DetailsViewModel {
  /// Emits the section that should be reloaded
  private(set) lazy var reloadSection: Driver<Int> = _reloadSection.asDriver(onErrorDriveWith: .never())
  
  private(set) lazy var profileAvatar: Single<UIImage?> = {
    return service.getProfile(for: profileId).map { profile in
      guard let avatarUrl = profile?.avatarUrl else { return nil }
      return UIImage(urlString: avatarUrl)
    }
  }()
  
  private let heroImage: UIImage?
  private var products = [Product]()
  private let productIds: [String]
  private var productImages = [String: UIImage]()
  private let service: ContentService
  private let profileId: String
  private let heroImageAspectRatio: CGFloat
  private let disposeBag = DisposeBag()
  private let _reloadSection = PublishRelay<Int>()
  
  init(detailsMetadata: DetailsViewModelDependencies, service: ContentService) {
    self.profileId = detailsMetadata.profileId
    self.heroImage = UIImage(urlString: detailsMetadata.heroImage)
    self.heroImageAspectRatio = detailsMetadata.heroImageAspectRatio
    self.productIds = detailsMetadata.productIds
    self.service = service
  }
  
  /// Fetches the linked products
  func fetchProducts() {
    service.getProducts(for: productIds)
      .subscribe(on: SerialDispatchQueueScheduler(qos: .userInitiated))
      .do(onSuccess: { [weak self] products in
        self?.products = products
        self?.productImages = products.reduce(into: [:]) { images, product in images[product.id] = UIImage(urlString: product.imageUrl)
        }
      })
      .subscribe(onSuccess: { [weak self] products in
        self?._reloadSection.accept(1)
      }).disposed(by: disposeBag)
  }
  
  func image(for section: Int, row: Int)  -> UIImage? {
    switch section {
    case 0:
      return heroImage
    case 1:
      let productId = productIds[row]
      return productImages[productId]
    default:
      return nil
    }
  }
  
  func numberOfItems(in section: Int) -> Int {
    switch section {
    case 0:
      return 1
    case 1:
      return productImages.count
    default:
      return 0
    }
  }
  
  func height(at indexPath: IndexPath, for width: CGFloat) -> CGFloat {
    switch indexPath.section {
    case 0:
      return heroImageAspectRatio * width
    case 1:
      return width
    default:
      return 0
    }
  }
  
  
  /// Returns a hyperlink to use to present a web view, if applicable. If nothing should be presented, returns `nil`
  /// - Parameters:
  ///   - section: the section of the item being selected
  ///   - row: the row of the item being selected
  /// - Returns: the url that should be opened in the web view, or `nil` if nothing should be presented
  func hyperlink(for section: Int, row: Int) -> URL? {
    guard section == 1 else { return nil }
    return URL(string: products[row].hyperlink)
  }
}
