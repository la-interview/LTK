//
//  FeedViewModel.swift
//  LTK
//
//  Created by Laura Artiles on 2/5/22.
//

import Foundation
import UIKit
import RxCocoa
import RxSwift

class FeedViewModel {
  /// The number of total items in the feed.
  var feedCount: Int {
    return metadata?.totalResults ?? 0
  }
  
  /// The number of current items fetched from the service to display on the feed.
  var currentCount: Int {
    return ltks.count
  }
  /// Notifies view controller the underlying data changed and the collection view should be reloaded
  private(set) lazy var reload: Driver<[IndexPath]?> = _reload.asDriver(onErrorJustReturn: nil)
  
  // MARK: - Private
  
  private let service: ContentService
  private var ltks = [LTK]()
  private var currentPage = 0
  private var isFetchInProgress = false
  private var metadata: Metadata?
  private var nextUrl: String? {
    return metadata?.nextUrl
  }
  private let disposeBag = DisposeBag()
  private var feedImages = [String: UIImage]()
  private let _reload = PublishRelay<[IndexPath]?>()
  
  init(contentService: ContentService) {
    self.service = contentService
    DispatchQueue.global(qos: .userInitiated).async { [weak self] in
      self?.fetchFeed()
    }
  }
  
  func detailsMetadata(at index: Int) -> DetailsViewModelDependencies {
    let ltk = ltks[index]
    return DetailsViewModelDependencies(heroImage: ltk.heroImage,
                                        heroImageAspectRatio: aspectRatioForImage(at: index),
                                        profileId: ltk.profileId,
                                        productIds: ltk.productIds)
  }
  
  func image(at index: Int) -> UIImage? {
    let id = ltks[index].id
    return feedImages[id]
  }
  
  private func aspectRatioForImage(at index: Int) -> CGFloat {
    let ltk = ltks[index]
    let aspectRatio = ltk.heroImageHeight.asCGFloat() / ltk.heroImageWidth.asCGFloat()
    return aspectRatio
  }
  
  func height(at index: Int, for width: CGFloat) -> CGFloat {
    return width * aspectRatioForImage(at: index)
  }
  
  func fetchFeed() {
    let url = currentPage == 0 ? LTKContentService.apiUrl : nextUrl
    service.getLtks(url: url)
      .subscribe(on: SerialDispatchQueueScheduler(qos: .userInitiated))
      .subscribe(onSuccess: { [weak self] ltks, metadata in
        guard let self = self else { return }
        self.currentPage += 1
        self.isFetchInProgress = false
        self.metadata = metadata
        
        self.feedImages = ltks.reduce(into: [:]) { images, ltk in images[ltk.id] = UIImage(urlString: ltk.heroImage)
        }
        self.ltks.append(contentsOf: ltks)
        
        if self.currentPage > 1 {
          let indexPathsToReload = self.calculateIndexPathsToReload(from: ltks)
          self._reload.accept(indexPathsToReload)
        }
        else {
          self._reload.accept(nil)
        }
      }, onFailure: { [weak self] error in
        self?.isFetchInProgress = false
      }).disposed(by: disposeBag)
  }
  
  private func calculateIndexPathsToReload(from newLtks: [LTK]) -> [IndexPath] {
    let startIndex = ltks.count - newLtks.count
    let endIndex = startIndex + newLtks.count
    return (startIndex..<endIndex).map { IndexPath(row: $0, section: 0) }
  }
}
