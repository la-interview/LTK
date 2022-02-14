//
//  UIImage+LTK.swift
//  LTK
//
//  Created by Laura Artiles on 2/11/22.
//

import UIKit

extension UIImage {
  // TODO: handle errors
  convenience init?(urlString: String) {
    guard let url = URL(string: urlString),
          let data = try? Data(contentsOf: url) else { return nil }
    self.init(data: data)
  }
}
