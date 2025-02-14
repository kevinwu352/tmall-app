//
//  Colors.swift
//  ModCommon
//
//  Created by Kevin Wu on 2022/1/1.
//

import UIKit

// Search: [COLORS]

public extension UIColor {

  static let main: UIColor = .red


  static var view_bg: UIColor { [UIColor(hex: 0xffffff), UIColor(hex: 0x121d30)][THEME.rawValue] }


  static var line:    UIColor { [UIColor(hex: 0xe0e8ef), UIColor(hex: 0x0d1626)][THEME.rawValue] }
  static var stripe:  UIColor { [UIColor(hex: 0xf1f3f8), UIColor(hex: 0x0d1626)][THEME.rawValue] }


  static var text_primary:    UIColor { [UIColor(hex: 0x1f3f59), UIColor(hex: 0xd8e1f0)][THEME.rawValue] }
  static var text_secondary:  UIColor { [UIColor(hex: 0x828ea1), UIColor(hex: 0x6a7a97)][THEME.rawValue] }
  static var text_tertiary:   UIColor { [UIColor(hex: 0xc5c9d5), UIColor(hex: 0x313e55)][THEME.rawValue] }

}
