//
//  UIView+LTK.swift
//  LTK
//
//  Created by Laura Artiles on 2/6/22.
//

import UIKit

extension UIView {
  func pin(to other: UIView) -> [NSLayoutConstraint] {
    return [
      topAnchor.constraint(equalTo: other.topAnchor),
      bottomAnchor.constraint(equalTo: other.bottomAnchor),
      leadingAnchor.constraint(equalTo: other.leadingAnchor),
      trailingAnchor.constraint(equalTo: other.trailingAnchor)
    ]
  }
  
  func center(in other: UIView) -> [NSLayoutConstraint] {
    return [
      centerXAnchor.constraint(equalTo: other.centerXAnchor),
      centerYAnchor.constraint(equalTo: other.centerYAnchor)
    ]
  }
}
