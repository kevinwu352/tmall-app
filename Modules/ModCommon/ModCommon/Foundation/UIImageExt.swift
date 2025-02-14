//
//  UIImageExt.swift
//  ModCommon
//
//  Created by Kevin Wu on 2022/1/1.
//

import UIKit

public extension UIImage {
  func scaleToFill(_ limit: CGSize) -> UIImage {
    UIGraphicsImageRenderer(size: limit).image {
      draw(in: $0.format.bounds)
    }
  }

  func scaleAspectFit(_ limit: CGSize) -> UIImage {
    let ratio = min(limit.width / size.width, limit.height / size.height)
    let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
    return UIGraphicsImageRenderer(size: newSize).image {
      draw(in: $0.format.bounds)
    }
  }

  func scaleAspectFill(_ limit: CGSize) -> UIImage {
    let ratio = max(limit.width / size.width, limit.height / size.height)
    let newRect = CGRect(x: (limit.width - size.width * ratio) / 2,
                         y: (limit.height - size.height * ratio) / 2,
                         width: size.width * ratio,
                         height: size.height * ratio)
    return UIGraphicsImageRenderer(size: limit).image { _ in
      draw(in: newRect)
    }
  }
}

public extension UIImage {
  var original: UIImage {
    withRenderingMode(.alwaysOriginal)
  }
  var template: UIImage {
    withRenderingMode(.alwaysTemplate)
  }
}
