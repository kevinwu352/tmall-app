//
//  ColorImage.swift
//  ModCommon
//
//  Created by Kevin Wu on 2022/1/1.
//

import UIKit

public extension UIColor {

  convenience init(hex: UInt) { // [F]
    self.init(red:   CGFloat(hex >> 16 & 0xff)/255,
              green: CGFloat(hex >> 8  & 0xff)/255,
              blue:  CGFloat(hex       & 0xff)/255,
              alpha: 1.0)
  }

  static func rand() -> UIColor {
    UIColor(red: .random(in: 0..<1), green: .random(in: 0..<1), blue: .random(in: 0..<1), alpha: 1)
  }

  // scale = screen scale
  var img: UIImage {
    UIGraphicsImageRenderer(size: CGSize(width: 8, height: 8)).image {
      setFill()
      $0.fill($0.format.bounds)
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
