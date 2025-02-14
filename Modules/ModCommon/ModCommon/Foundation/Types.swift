//
//  Types.swift
//  ModCommon
//
//  Created by Kevin Wu on 2022/1/1.
//

import UIKit

// Callbacks
public typealias VoidCb = () -> Void

// Error
public struct Err: LocalizedError {
  public var code: Int
  public var info: String
  public init(_ code: Int, _ info: String) {
    self.code = code
    self.info = info
  }
  public var errorDescription: String? {
    info
  }
}


// MARK: Int / Double / String

// Int - Double
public extension BinaryInteger {
  var int: Int { Int(self) }
  var dbl: Double { Double(self) }
}
public extension BinaryFloatingPoint {
  var dbl: Double { Double(self) }
  var int: Int { Int(self) }
}

// Int - String
public extension Int {
  var str: String { String(self, radix: 10, uppercase: false) }
}
public extension String {
  var int: Int? { Int(self, radix: 10) }
}

// Double - String
public extension Double {
  var str: String { String(format: "%f", self) }
}
public extension String {
  var dbl: Double? { Double(self) }
}


// MARK: Data / Hex

// Data - String
public extension Data {
  var str: String { String(decoding: self, as: UTF8.self) }
}
public extension String {
  var dat: Data { Data(utf8) }
}

// HexData - String
public extension Data {
  var hexstr: String {
    map { String(format: "%02x", $0) }
      .joined(separator: "")
  }
}
public extension String {
  var hexdat: Data? {
    assert(count%2 == 0, "`count` should not be odd")
    var data = Data()
    for i in 0..<count/2 {
      let beg = index(startIndex, offsetBy: i*2)
      let end = index(beg, offsetBy: 2)
      let byte = self[beg..<end]
      if var num = UInt8(byte, radix: 16) {
        data.append(&num, count: 1)
      } else {
        return nil
      }
    }
    return data
  }
}

// HexInt - String
public extension Int {
  var hexstr: String { String(self, radix: 16, uppercase: false) }
}
public extension String {
  var hexint: Int? { Int(self, radix: 16) }
}
