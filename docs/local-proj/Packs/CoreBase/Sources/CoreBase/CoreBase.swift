// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import UIKit

@MainActor
public func doit() -> UIImageView {
  let iv = UIImageView()
//  iv.image = UIImage(resource: .flatCloud)
//  iv.image = R.image.com.flat_cloud_1()
  return iv
}

@MainActor
public func doit2() -> UILabel {
  let v = UILabel()
  v.text = NSLocalizedString("hello", bundle: .module, comment: "")
  return v
}


//public extension ImageResource {
//  static let kkk = ImageResource.flatCloud
//}
public extension UIImage {
  // 用这种
  static var kFlatCloud: UIImage {
    UIImage(resource: .flatCloud)
  }
}

public extension String {
  static var kWelcomeMsg: String {
    NSLocalizedString("god", bundle: .module, comment: "")
  }
}
