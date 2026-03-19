//
//  TextLimiter.swift
//  ModCommon
//
//  Created by Kevin Wu on 3/19/26.
//

import UIKit

extension UITextField {
  public var limiter: TextLimiter? {
    get {
      objc_getAssociatedObject(self, &kTextFieldLimiterKey) as? TextLimiter
    }
    set {
      objc_setAssociatedObject(self, &kTextFieldLimiterKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
      delegate = newValue
    }
  }
}
private nonisolated(unsafe) var kTextFieldLimiterKey = 0

open class TextLimiter: NSObject, UITextFieldDelegate {

  public init(maxLength: Int = 0, allowedCharset: CharacterSet? = nil) {
    self.maxLength = maxLength
    self.allowedCharset = allowedCharset
    super.init()
  }
  public let maxLength: Int
  public let allowedCharset: CharacterSet?

  public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    guard !string.isEmpty else { return true }
    let text = ((textField.text ?? "") as NSString).replacingCharacters(in: range, with: string)
    return shouldChangeCharacters(text)
  }

  open func shouldChangeCharacters(_ text: String) -> Bool {
    if maxLength > 0 {
      if text.count > maxLength {
        return false
      }
    }
    if let allowedCharset {
      if !allowedCharset.isSuperset(of: CharacterSet(charactersIn: text)) {
        return false
      }
    }
    return true
  }

}

// open class IntLimiter: TextLimiter {
//   public init(maxLength: Int = 0, negativable: Bool = false, min: String? = nil, max: String? = nil) {
//     self.min = min
//     self.max = max
//     super.init(maxLength: maxLength, allowedCharset: CharacterSet(charactersIn: "0123456789" + (negativable ? "-" : "")))
//   }
//   public let min: String?
//   public let max: String?
//   open override func shouldChangeCharacters(_ text: String) -> Bool {
//     guard super.shouldChangeCharacters(text) else { return false }
//     if let max {
//       if text.padded > max.padded {
//         return false
//       }
//     }
//     return true
//   }
// }

// extension String {
//   fileprivate var padded: String {
//     var str = self + (contains(".") ? "" : ".")
//     while let i = str.firstIndex(of: "."), str[..<i].count < 30 {
//       str = "0" + str
//     }
//     while let i = str.firstIndex(of: "."), str[i...].count < 30 {
//       str = str + "0"
//     }
//     return str
//   }
// }
