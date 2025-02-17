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


  enum PadStyle {
    case exact(_ with: String?) // 长切短补
    case padded(_ with: String?) // 短补
    case truncated // 长切
  }
  func relened(_ length: Int, _ style: PadStyle) -> String {
    switch style {
    case let .exact(str):
      return padding(toLength: length, withPad: str ?? " ", startingAt: 0)
    case let .padded(str):
      return count < length ? padding(toLength: length, withPad: str ?? " ", startingAt: 0) : self
    case .truncated:
      return count > length ? padding(toLength: length, withPad: "", startingAt: 0) : self
    }
  }
  func trimmed() -> String {
    trimmingCharacters(in: .whitespacesAndNewlines)
  }

  func prefixed(_ str: String?, _ sep: String? = nil) -> String { // FUNC
    if let str = str, str.notEmpty {
      return str + (sep ?? "") + self
    } else {
      return self
    }
  }
  func suffixed(_ str: String?, _ sep: String? = nil) -> String { // FUNC
    if let str = str, str.notEmpty {
      return self + (sep ?? "") + str
    } else {
      return self
    }
  }


  func split(_ sep: Character) -> [String] {
    split(separator: sep, maxSplits: Int.max, omittingEmptySubsequences: false)
      .map { String($0) }
  }

  func indented(_ pre: String?) -> String {
    split("\n")
      .map { (pre ?? "") + $0 }
      .joined(separator: "\n")
  }

  // "$1 $2 $3".feed("aa", nil, "bb")
  // "%c %d %u %f %s".feed("aa", nil, "bb")
  func feed(_ values: String?...) -> String {
    var str = self
    str = values.enumerated().reduce(str) {
      $0.replacingOccurrences(of: "$\($1.offset + 1)", with: $1.element ?? "")
    }
    ["%c", "%d", "%u", "%f", "%s"].enumerated().forEach {
      if values.count > $0.offset {
        let val = values[$0.offset] ?? ""
        str = str.replacingOccurrences(of: $0.element, with: val)
      }
    }
    return str
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


// MARK: Numbers

public extension String {

  var numbered: String {
    let set = "0123456789.-+"
    var str = self
    str.removeAll { !set.contains($0) }
    return str
  }

  var plused: String {
    if hasPrefix("+") || hasPrefix("-") {
      return self
    } else {
      return "+" + self
    }
  }
  var unplused: String {
    if hasPrefix("+") {
      return suffix(from: idx(1)).sup
    } else {
      return self
    }
  }
  var unsigned: String {
    if hasPrefix("+") || hasPrefix("-") {
      return suffix(from: idx(1)).sup
    } else {
      return self
    }
  }

  var grouped: String {
    var str = replacingOccurrences(of: ",", with: "")
    let start = str.startIndex
    let begin = str.firstIndex(of: ".") ?? str.endIndex
    var offset = -3
    while let i = str.index(begin, offsetBy: offset, limitedBy: start) {
      if let c = str[..<i].last {
        if "0123456789".contains(c) {
          // ...
        } else {
          break
        }
      } else {
        break
      }
      str.insert(",", at: i)
      offset -= 3
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
  // truncating 换行模式只能算出单行高度，所以请将 .byTruncatingTail 改成 .byWordWrapping
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
  ) -> NSMutableParagraphStyle { // FUNC
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
