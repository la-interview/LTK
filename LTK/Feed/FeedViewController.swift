//
//  FeedViewController.swift
//  LTK
//
//  Created by Laura Artiles on 2/5/22.
//

import RxCocoa
import RxSwift
import UIKit

class FeedViewController: UIViewController {
  private let viewModel: FeedViewModel
  private lazy var collectionView = UICollectionView(frame: view.frame,
                                                     collectionViewLayout: UICollectionViewFlowLayout())
  
  private static let reuseIdentifier = "FeedCell"
  private let factory: LTKViewControllerFactory
  private let disposeBag = DisposeBag()
  
  init(viewModel: FeedViewModel, factory: LTKViewControllerFactory) {
    self.viewModel = viewModel
    self.factory = factory
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupCollectionView()
    
    viewModel.reload.drive(onNext: { [weak self] indexPaths in
      guard let indexPaths = indexPaths else {
        self?.collectionView.reloadData()
        return
      }
      self?.collectionView.reloadItems(at: indexPaths)
    }).disposed(by: disposeBag)
  }
  
  func setupCollectionView() {
    collectionView.delegate = self
    collectionView.dataSource = self
    collectionView.prefetchDataSource = self
    collectionView.backgroundColor = .white
    collectionView.register(ImageCell.self, forCellWithReuseIdentifier: FeedViewController.reuseIdentifier)
    collectionView.translatesAutoresizingMaskIntoConstraints = false
    
    view.addSubview(collectionView)
  }
}

extension FeedViewController: UICollectionViewDataSourcePrefetching {
  func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
    if indexPaths.contains(where: { $0.row >= viewModel.currentCount }) {
      viewModel.fetchFeed()
    }
  }
}

extension FeedViewController: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let viewController = factory.makeDetailsViewController(with: viewModel.detailsMetadata(at: indexPath.row))
    navigationController?.pushViewController(viewController, animated: true)
  }
}

extension FeedViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    if indexPath.row >= viewModel.currentCount {
      return .zero
    }
    let width = view.frame.width
    let height = viewModel.height(at: indexPath.row, for: width)
    return CGSize(width: width, height: height)
  }
}

extension FeedViewController: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return viewModel.feedCount
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FeedViewController.reuseIdentifier, for: indexPath) as? ImageCell else {
      preconditionFailure("Failed to dequeue cell")
    }
    if indexPath.row >= viewModel.currentCount {
      return cell
    }
    cell.setImage(viewModel.image(at: indexPath.row))
    return cell
  }
}

