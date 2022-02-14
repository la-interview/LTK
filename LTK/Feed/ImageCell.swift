//
//  ImageCell.swift
//  LTK
//
//  Created by Laura Artiles on 2/6/22.
//

import Foundation
import UIKit

class ImageCell: UICollectionViewCell {
  private lazy var imageView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .scaleAspectFit
    imageView.translatesAutoresizingMaskIntoConstraints = false
    return imageView
  }()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    contentView.addSubview(imageView)
    configureConstraints()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func prepareForReuse() {
    imageView.image = nil
  }
  
  func configureConstraints() {
    NSLayoutConstraint.activate(
      imageView.pin(to: contentView)
    )
  }
  
  func setImage(_ image: UIImage?) {
    DispatchQueue.main.async { [weak self] in
      self?.imageView.image = image
    }
  }
}
