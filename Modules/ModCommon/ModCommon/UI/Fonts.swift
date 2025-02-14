//
//  Fonts.swift
//  ModCommon
//
//  Created by Kevin Wu on 2022/1/1.
//

import UIKit

// Search: [FONTS]

public extension UIFont {

  // https://developer.apple.com/design/human-interface-guidelines/ios/visual-design/typography/
  // https://learnui.design/blog/ios-font-size-guidelines.html

  static let h1   = UIFont.systemFont(ofSize: 28, weight: .regular)
  static let h1_m = UIFont.systemFont(ofSize: 28, weight: .medium)
  static let h1_b = UIFont.systemFont(ofSize: 28, weight: .bold)

  static let h2   = UIFont.systemFont(ofSize: 24, weight: .regular)
  static let h2_m = UIFont.systemFont(ofSize: 24, weight: .medium)
  static let h2_b = UIFont.systemFont(ofSize: 24, weight: .bold)

  static let h3   = UIFont.systemFont(ofSize: 18, weight: .regular)
  static let h3_m = UIFont.systemFont(ofSize: 18, weight: .medium)
  static let h3_b = UIFont.systemFont(ofSize: 18, weight: .bold)


  static let head   = UIFont.systemFont(ofSize: 16, weight: .regular)
  static let head_m = UIFont.systemFont(ofSize: 16, weight: .medium)
  static let head_b = UIFont.systemFont(ofSize: 16, weight: .bold)

  static let primary    = UIFont.systemFont(ofSize: 14, weight: .regular)
  static let primary_m  = UIFont.systemFont(ofSize: 14, weight: .medium)
  static let primary_b  = UIFont.systemFont(ofSize: 14, weight: .bold)

  static let secondary    = UIFont.systemFont(ofSize: 12, weight: .regular)
  static let secondary_m  = UIFont.systemFont(ofSize: 12, weight: .medium)
  static let secondary_b  = UIFont.systemFont(ofSize: 12, weight: .bold)

  static let tertiary   = UIFont.systemFont(ofSize: 10, weight: .regular)
  static let tertiary_m = UIFont.systemFont(ofSize: 10, weight: .medium)
  static let tertiary_b = UIFont.systemFont(ofSize: 10, weight: .bold)

}
