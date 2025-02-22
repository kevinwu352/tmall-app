//
//  TextLimiter.swift
//  ModCommon
//
//  Created by Kevin Wu on 2022/1/1.
//

import UIKit

open class TextLimiter: NSObject, UITextFieldDelegate {

  public init(maxLength: Int?, allowedCharset: CharacterSet?) {
    super.init()
    self.maxLength = maxLength
    self.allowedCharset = allowedCharset
  }

  public var maxLength: Int?

  public var allowedCharset: CharacterSet?


  open func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    guard string.count > 0 else { return true }
    let currentText = textField.text ?? ""
    let newText = currentText.replacingCharacters(in: range.in(currentText), with: string)

    if let maxLength = maxLength, maxLength > 0 {
      if newText.count <= maxLength {
        // ...
      } else {
        return false
      }
    }

    if let allowedCharset = allowedCharset {
      if !allowedCharset.isSuperset(of: string.charset) {
        return false
      }
    }

    return true
  }

}


open class NumberLimiter: TextLimiter {

  public init(style: Style, min: String? = nil, max: String? = nil) {
    self.style = style
    self.min = min
    self.max = max
    super.init(maxLength: nil, allowedCharset: style.charset)
  }

  public enum Style {
    case natural
    case integer
    case nonnegative(_ places: Int?)
    case rational(_ places: Int?)
    var regex: String {
      switch self {
      case .natural: return #"^\d*$"#
      case .integer: return #"^-?\d*$"#
      case let .nonnegative(places):
        if let places = places, places > 0 {
          return String(format: #"^\d*(\.\d{0,%d})?$"#, places)
        } else {
          return #"^\d*(\.\d*)?$"#
        }
      case let .rational(places):
        if let places = places, places > 0 {
          return String(format: #"^-?\d*(\.\d{0,%d})?$"#, places)
        } else {
          return #"^-?\d*(\.\d*)?$"#
        }
      }
    }
    var charset: CharacterSet? {
      switch self {
      case .natural: return "0123456789".charset
      case .integer: return "0123456789-".charset
      case .nonnegative: return "0123456789.".charset
      case .rational: return "0123456789.-".charset
      }
    }
  }
  public var style: Style {
    didSet { allowedCharset = style.charset }
  }

  public var min: String?
  public var max: String?


  open override func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    if !super.textField(textField, shouldChangeCharactersIn: range, replacementString: string) {
      return false
    }

    guard string.count > 0 else { return true }
    let currentText = textField.text ?? ""
    let newText = currentText.replacingCharacters(in: range.in(currentText), with: string)

    if !newText.regexTest(style.regex) {
      return false
    }

    if let num = Num(newText).finited {
      if let min = Num(min).finited, num < min {
        return false
      }
      if let max = Num(max).finited, num > max {
        return false
      }
    }

    return true
  }

}


public extension UITextField {
  var limiter: TextLimiter? {
    get {
      objc_getAssociatedObject(self, &kLimiterKey) as? TextLimiter
    }
    set {
      objc_setAssociatedObject(self, &kLimiterKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
      delegate = newValue
    }
  }
}
fileprivate var kLimiterKey: UInt8 = 0
