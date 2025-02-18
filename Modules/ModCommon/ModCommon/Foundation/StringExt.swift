//
//  StringExt.swift
//  ModCommon
//
//  Created by Kevin Wu on 2022/1/1.
//

import UIKit

public let SEP_LINE = "\u{2028}"
public let SEP_PARA = "\u{2029}"
/*
 str = """
   Line 1
   Line 2
   """

 str = """
   Line 1 \
   Line 1
   """

 str = #"Line 1 \nLine 1"#

 str = #"""
   Here are three more double quotes: """
   """#
 */

public extension String {
  var charset: CharacterSet {
    CharacterSet(charactersIn: self)
  }

  var url: URL? {
    URL(string: self)
  }
  var furl: URL {
    URL(fileURLWithPath: self)
  }

  func attributed(_ font: UIFont?, _ color: UIColor?) -> AttributedString {
    AttributedString(self, attributes: AttributeContainer([.font:font as Any, .foregroundColor:color as Any]))
  }


  // nil:exact / true:pad / false:truncate
  func relened(_ len: Int, _ with: String?, _ pad: Bool?) -> String {
    if pad == true {
      return count < len ? padding(toLength: len, withPad: with ?? " ", startingAt: 0) : self
    } else if pad == false {
      return count > len ? padding(toLength: len, withPad: "", startingAt: 0) : self
    } else {
      return padding(toLength: len, withPad: with ?? " ", startingAt: 0)
    }
  }
  func trimmed() -> String {
    trimmingCharacters(in: .whitespacesAndNewlines)
  }


  func prefixed(_ str: String?, _ sep: String? = nil) -> String {
    if let str = str, str.notEmpty {
      return str + (sep ?? "") + self
    } else {
      return self
    }
  }
  func suffixed(_ str: String?, _ sep: String? = nil) -> String {
    if let str = str, str.notEmpty {
      return self + (sep ?? "") + str
    } else {
      return self
    }
  }


  // "$1 $2 $3".feed("aa", nil, "bb")
  // "%c %d %u %f %s".feed("aa", nil, "bb")
  func feed(_ values: String?...) -> String {
    var str = self
    str = values.enumerated().reduce(str) {
      $0.replacingOccurrences(of: "$\($1.offset + 1)", with: $1.element ?? "")
    }
    str = values.enumerated().reduce(str) {
      $0.replacingOccurrences(of: ["%c", "%d", "%u", "%f", "%s"].at($1.offset) ?? "", with: $1.element ?? "")
    }
    return str
  }
}


// MARK: Numbers

public extension String {
  var numbered: String {
    var str = self
    str.removeAll { !"0123456789.-+".contains($0) }
    return str
  }

  var plused: String {
    hasPrefix("+") || hasPrefix("-") ? self : "+" + self
  }
  var unplused: String {
    hasPrefix("+") ? suffix(from: index(after: startIndex)).sup : self
  }
  var unsigned: String {
    hasPrefix("+") || hasPrefix("-") ? suffix(from: index(after: startIndex)).sup : self
  }

  var grouped: String {
    var str = replacingOccurrences(of: ",", with: "")
    let start = str.startIndex
    let begin = str.firstIndex(of: ".") ?? str.endIndex
    var offset = -3
    while let i = str.index(begin, offsetBy: offset, limitedBy: start) {
      if let c = str[..<i].last, "0123456789".contains(c) {
        str.insert(",", at: i)
        offset -= 3
      } else {
        break
      }
    }
    return str
  }

  func zeroTrimmed() -> String {
    var str = self
    while let i = str.firstIndex(of: "."), str[i...].hasSuffix("0") {
      str.removeLast()
    }
    if str.hasSuffix(".") {
      str.removeLast()
    }
    return str
  }
  func zeroPadded(_ len: Int) -> String {
    var str = self + (contains(".") ? "" : ".")
    while let i = str.firstIndex(of: "."), str[i...].count < len + 1 {
      str += "0"
    }
    if str.hasSuffix(".") {
      str.removeLast()
    }
    return str
  }
}


// MARK: Sizing

public extension String {
  // 单行
  func calcSize(_ font: UIFont?, _ limit: Double?) -> CGSize {
    let size = self.size(withAttributes: [.font: font as Any])
    if let limit = limit, limit > 0 {
      return CGSize(width: min(limit, size.width), height: size.height)
    } else {
      return size
    }
  }
  // 多段多行/单段多行，宽度一定要限，高度可以不限
  // byTruncatingTail 只能算出单行高度，所以要改成 byWordWrapping
  // byTruncatingTail 只说了如何截取，它隐含的换行模式是 byWordWrapping
  // textAlignment 和 lineBreakMode 在 attributed 中也会起作用
  func calcSize(_ attrs: [NSAttributedString.Key:Any], _ limit: CGSize) -> CGSize {
    let rect = self.boundingRect(with: limit.rh(.greatestFiniteMagnitude),
                                 options: [.usesLineFragmentOrigin, .usesFontLeading, .truncatesLastVisibleLine],
                                 attributes: attrs,
                                 context: nil)
    if limit.height > 0 {
      return CGSize(width: min(limit.width, rect.width), height: min(limit.height, rect.height))
    } else {
      return CGSize(width: min(limit.width, rect.width), height: rect.height)
    }
  }
}

public extension NSParagraphStyle {
  static func fromBase(base: NSParagraphStyle?,
                       alignment: NSTextAlignment? = nil,
                       breakMode: NSLineBreakMode? = nil,
                       lineHeight: Double? = nil
  ) -> NSMutableParagraphStyle {
    let ret = (base ?? NSMutableParagraphStyle.default).mutableCopy() as? NSMutableParagraphStyle ?? NSMutableParagraphStyle()
    if let alignment = alignment {
      ret.alignment = alignment
    }
    if let breakMode = breakMode {
      ret.lineBreakMode = breakMode
    }
    if let lineHeight = lineHeight {
      ret.minimumLineHeight = lineHeight
    }
    return ret
  }
}


// MARK: Regex

public extension String {
  func regexMatch(_ regex: String) -> [Range<Index>] {
    var list: [Range<Index>] = []
    if let detector = try? NSRegularExpression(pattern: regex, options: []) {
      detector.enumerateMatches(in: self, options: [], range: NSMakeRange(0, count)) { result, flags, _ in
        if let result = result {
          list.append(result.range.in(self))
        }
      }
    }
    return list
  }
  func regexTest(_ regex: String) -> Bool {
    regexMatch(regex).notEmpty
  }
  func regexExtract(_ regex: String) -> String? {
    if let range = regexMatch(regex).first {
      return self[range].sup
    }
    return nil
  }
}
