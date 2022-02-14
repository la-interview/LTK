//
//  LTKViewControllerFactory.swift
//  LTK
//
//  Created by Laura Artiles on 2/6/22.
//

import UIKit

protocol ViewControllerFactory {
  func makeFeedViewController() -> UIViewController
  func makeDetailsViewController(with detailsMetadata: DetailsViewModelDependencies) -> UIViewController
  func makeProductViewController(with hyperlink: URL) -> UIViewController
}

class LTKViewControllerFactory: ViewControllerFactory {
  private let service: ContentService
  
  init(service: ContentService) {
    self.service = service
  }
  
  func makeFeedViewController() -> UIViewController {
    let viewModel = FeedViewModel(contentService: service)
    return FeedViewController(viewModel: viewModel, factory: self)
  }
  
  func makeDetailsViewController(with detailsMetadata: DetailsViewModelDependencies) -> UIViewController {
    let viewModel = DetailsViewModel(detailsMetadata: detailsMetadata, service: service)
    return DetailsViewController(viewModel: viewModel, factory: self)
  }
  
  func makeProductViewController(with hyperlink: URL) -> UIViewController {
    return WebViewController(productUrl: hyperlink)
  }
}
