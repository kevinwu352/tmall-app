//
//  Metric.swift
//  ModCommon
//
//  Created by Kevin Wu on 2022/1/1.
//

import UIKit

// MARK: Main Elements

public var APP_VERSION: String {
  Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
}
public var APP_BUILD: String {
  Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""
}

public var WINDOW: UIWindow? {
  UIApplication.shared.delegate?.window as? UIWindow
}
public var MODALTOP: UIViewController? {
  var ret = WINDOW?.rootViewController
  while let vc = ret?.presentedViewController {
    ret = vc
  }
  return ret
}

// https://www.screensizes.app/?compare=iphone

public let SCREEN_WID = Double(UIScreen.main.bounds.width)
public let SCREEN_HET = Double(UIScreen.main.bounds.height)

public let SAFE_TOP = Double(WINDOW?.safeAreaInsets.top ?? 0.0)
public let SAFE_BOT = Double(WINDOW?.safeAreaInsets.bottom ?? 0.0)

public let NOTCH = SAFE_BOT > 0

public let STATUS_BAR_HET = NOTCH ? SAFE_TOP : 20.0
public let NAV_BAR_HET = 44.0
public let TOP_HET = STATUS_BAR_HET + NAV_BAR_HET

public let TAB_BAR_HET = 49.0
public let BOT_HET = SAFE_BOT + TAB_BAR_HET


// MARK: Geometry

public extension CGPoint {
  func rx(_ val: Double) -> CGPoint { CGPoint(x: val, y: y) }
  func ry(_ val: Double) -> CGPoint { CGPoint(x: x, y: val) }
  func ox(_ val: Double) -> CGPoint { CGPoint(x: x + val, y: y) }
  func oy(_ val: Double) -> CGPoint { CGPoint(x: x, y: y + val) }
}

public extension CGSize {
  func rw(_ val: Double) -> CGSize { CGSize(width: val, height: height) }
  func rh(_ val: Double) -> CGSize { CGSize(width: width, height: val) }
  func ow(_ val: Double) -> CGSize { CGSize(width: width + val, height: height) }
  func oh(_ val: Double) -> CGSize { CGSize(width: width, height: height + val) }
}

public extension CGRect {
  func rx(_ val: Double) -> CGRect { CGRect(x: val, y: minY, width: width, height: height) }
  func ry(_ val: Double) -> CGRect { CGRect(x: minX, y: val, width: width, height: height) }
  func rw(_ val: Double) -> CGRect { CGRect(x: minX, y: minY, width: val, height: height) }
  func rh(_ val: Double) -> CGRect { CGRect(x: minX, y: minY, width: width, height: val) }
  func ox(_ val: Double) -> CGRect { CGRect(x: minX + val, y: minY, width: width, height: height) }
  func oy(_ val: Double) -> CGRect { CGRect(x: minX, y: minY + val, width: width, height: height) }
  func ow(_ val: Double) -> CGRect { CGRect(x: minX, y: minY, width: width + val, height: height) }
  func oh(_ val: Double) -> CGRect { CGRect(x: minX, y: minY, width: width, height: height + val) }
}


// MARK: Uncat

public extension CGSize {
  // aspect fit / aspect fill
  func ratio(_ limit: CGSize, _ fit: Bool) -> Double {
    fit ? min(limit.width / width, limit.height / height) : max(limit.width / width, limit.height / height)
  }
}

public extension UIEdgeInsets {
  var vertical: CGFloat { top + bottom }
  var horizontal: CGFloat { left + right }
}
