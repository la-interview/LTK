//
//  DetailsViewController.swift
//  LTK
//
//  Created by Laura Artiles on 2/6/22.
//

import Foundation
import UIKit
import RxCocoa
import RxSwift

class DetailsViewController: UIViewController {
  private let viewModel: DetailsViewModel
  private let activityIndicatorView = UIActivityIndicatorView(style: .medium)
  private lazy var collectionView = UICollectionView(frame: view.frame,
                                                     collectionViewLayout: UICollectionViewFlowLayout())
  
  private static let heroReuseIdentifier = "HeroCell"
  private static let productSectionReuseIdentifier = "ProductSectionCell"
  private static let productsPerRow: CGFloat = 4
  private let factory: ViewControllerFactory
  private let disposeBag = DisposeBag()
  
  init(viewModel: DetailsViewModel, factory: ViewControllerFactory) {
    self.viewModel = viewModel
    self.factory = factory
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setUpCollectionView()
    setUpLoadingSpinner()
    setUpAvatar()
    
    viewModel.reloadSection.drive(onNext: { [weak self] section in
      self?.activityIndicatorView.stopAnimating()
      self?.collectionView.reloadSections(IndexSet(integer: section))
    }).disposed(by: disposeBag)
    
    viewModel.fetchProducts()
  }
  
  func setUpCollectionView() {
    collectionView.delegate = self
    collectionView.dataSource = self
    collectionView.backgroundColor = .white
    collectionView.register(ImageCell.self, forCellWithReuseIdentifier: DetailsViewController.heroReuseIdentifier)
    collectionView.translatesAutoresizingMaskIntoConstraints = false
    
    view.addSubview(collectionView)
  }
  
  func setUpLoadingSpinner() {
    view.addSubview(activityIndicatorView)
    activityIndicatorView.hidesWhenStopped = true
    activityIndicatorView.center = self.view.center
    activityIndicatorView.startAnimating()
  }
  
  func setUpAvatar() {
    let imageView = UIImageView()
    imageView.contentMode = .scaleAspectFit
    self.navigationItem.titleView = imageView
    
    viewModel.profileAvatar
      .asDriver(onErrorJustReturn: nil)
      .drive(imageView.rx.image)
      .disposed(by: disposeBag)
  }
}

extension DetailsViewController: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    guard let hyperlink = viewModel.hyperlink(for: indexPath.section, row: indexPath.row) else { return }
    
    let viewController = factory.makeProductViewController(with: hyperlink)
    navigationController?.pushViewController(viewController, animated: true)
  }
}

extension DetailsViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let width: CGFloat
    
    let availableWidth = collectionView.bounds.inset(by: collectionView.layoutMargins).width
    switch indexPath.section {
    case 0:
      width = availableWidth
    case 1:
      let paddingSpace = collectionView.layoutMargins.left * (DetailsViewController.productsPerRow - 1)
      width = (availableWidth - paddingSpace) / DetailsViewController.productsPerRow
    default:
      return .zero
    }
    let height = viewModel.height(at: indexPath, for: width)
    return CGSize(width: width, height: height)
  }
  
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 2
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
    switch section {
    case 0:
      return UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
    case 1:
      return UIEdgeInsets(top: 10, left: 5, bottom: 0, right: 5)
    default:
      return .zero
    }
  }
}

extension DetailsViewController: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    viewModel.numberOfItems(in: section)
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DetailsViewController.heroReuseIdentifier, for: indexPath)
    guard let imageCell = cell as? ImageCell else {
      preconditionFailure("Failed to dequeue hero cell")
    }
    
    let image = viewModel.image(for: indexPath.section, row: indexPath.row)
    imageCell.setImage(image)
    return imageCell
  }
}
