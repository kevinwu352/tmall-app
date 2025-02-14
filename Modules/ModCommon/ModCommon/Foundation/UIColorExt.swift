//
//  UIColorExt.swift
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
