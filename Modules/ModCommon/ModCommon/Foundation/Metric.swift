//
//  Metric.swift
//  ModCommon
//
//  Created by Kevin Wu on 2022/1/1.
//

import UIKit

// 15/16 6.1
// Screen resolution (points): 393 x 852
// Native resolution (pixels): 1179 x 2556 (460 ppi)
// Safe Area Insets (portrait): top: 59, bottom: 34, left: 0, right: 0
// Safe Area Insets (landscape): top: 0, bottom: 21, left: 59, right: 59
// 灵动岛高 54，但安全区高 59
// 如果有导航条，上面安全区留的位置是 53.67，导航条 44，总共是 97.67
// 如果没导航条，视图顶上接安全区，上面的留白是 59
// ScrollView.adjustedContentInset: {97.666666666666671, 0, 83, 0}，83-34=49，所以，TabBar 高度 49
//
// 17/17P 6.3
// Screen resolution (points): 402 x 874
// Native resolution (pixels): 1206 x 2622 (460 ppi)
// Safe Area Insets (portrait): top: 62, bottom: 34, left: 0, right: 0
// Safe Area Insets (landscape): top: 20, bottom: 20, left: 62, right: 62
// 灵动岛高 54，但安全区高 62
// 如果有导航条，上面安全区留的位置是 62，导航条 54，总共是 116
// 如果没导航条，视图顶上接安全区，上面的留白是 62
// ScrollView.adjustedContentInset: {116, 0, 83, 0}，83-34=49，所以，TabBar 高度 49

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

public let SCREEN_SCL = UIScreen.main.scale == 3.0 ? 3 : 2

public let SCREEN_WID = Double(UIScreen.main.bounds.width)
public let SCREEN_HET = Double(UIScreen.main.bounds.height)

public let SAFE_TOP = Double(WINDOW?.safeAreaInsets.top ?? 0.0)
public let SAFE_BOT = Double(WINDOW?.safeAreaInsets.bottom ?? 0.0)

public let NOTCH = SAFE_BOT > 0

public let STATUS_BAR_HET = NOTCH ? SAFE_TOP : 20.0
public let NAV_BAR_HET = 44.0
public let TAB_BAR_HET = 49.0

public let TOP_HET = STATUS_BAR_HET + NAV_BAR_HET
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

public extension UIEdgeInsets {
  var vertical: CGFloat { top + bottom }
  var horizontal: CGFloat { left + right }
}
