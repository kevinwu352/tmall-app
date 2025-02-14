//
//  UIImageExt.swift
//  ModCommon
//
//  Created by Kevin Wu on 2022/1/1.
//

import UIKit

public extension UIImage {
  var original: UIImage {
    withRenderingMode(.alwaysOriginal)
  }
  var template: UIImage {
    withRenderingMode(.alwaysTemplate)
  }
}

public extension UIImage {
  func scaleToFill(_ limit: CGSize) -> UIImage {
    UIGraphicsImageRenderer(size: limit).image {
      draw(in: $0.format.bounds)
    }
  }

  func scaleAspectFit(_ limit: CGSize) -> UIImage {
    let ratio = size.ratio(limit, true)
    let sz = CGSize(width: size.width * ratio, height: size.height * ratio)
    return UIGraphicsImageRenderer(size: sz).image {
      draw(in: $0.format.bounds)
    }
  }

  func scaleAspectFill(_ limit: CGSize) -> UIImage {
    let ratio = size.ratio(limit, false)
    let rt = CGRect(x: (limit.width - size.width * ratio) / 2.0,
                    y: (limit.height - size.height * ratio) / 2.0,
                    width: size.width * ratio,
                    height: size.height * ratio)
    return UIGraphicsImageRenderer(size: limit).image { _ in
      draw(in: rt)
    }
  }
}
