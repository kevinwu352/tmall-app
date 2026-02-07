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
  public init(_ c: Int, _ i: String) {
    code = c
    info = i
  }
  public var errorDescription: String? {
    info
  }
}

// SubSequence
public extension Substring {
  var sup: String { String(self) }
}
public extension ArraySlice {
  var sup: Array<Element> { Array(self) }
}


// MARK: Int / Double / String

// Int - Double
public extension BinaryInteger {
  var i: Int { Int(self) }
  var d: Double { Double(self) }
}
public extension BinaryFloatingPoint {
  var d: Double { Double(self) }
  var i: Int { Int(self) }
}

// Int - String
public extension Int {
  var s: String { String(self, radix: 10, uppercase: false) }
}
public extension String {
  var i: Int? { Int(self, radix: 10) }
}

// Double - String
public extension Double {
  var s: String { String(format: "%f", self) }
}
public extension String {
  var d: Double? { Double(self) }
}


// MARK: Data / Hex

// Data - String
public extension Data {
  var utf8str: String { String(decoding: self, as: UTF8.self) }
}
public extension String {
  var utf8dat: Data { Data(utf8) }
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


// MARK: Numbers

// BinaryInteger
//    Int,  Int8,  Int16,  Int32,  Int64
//   UInt, UInt8, UInt16, UInt32, UInt64
// BinaryFloatingPoint
//   Double
//   Float, Float16, Float32=Float, Float64=Double, Float80
//   CGFloat

// number to int
public func n2i(_ val: Any?) -> Int? {
  if let val = val as? (any BinaryInteger) {
    return Int(val)
  } else if let val = val as? (any BinaryFloatingPoint) {
    return Int(val)
  } else {
    return nil
  }
}
// number to double
public func n2d(_ val: Any?) -> Double? {
  if let val = val as? (any BinaryInteger) {
    return Double(val)
  } else if let val = val as? (any BinaryFloatingPoint) {
    return Double(val)
  } else {
    return nil
  }
}

// any to int
public func a2i(_ val: Any?) -> Int? {
  if let val = val as? (any BinaryInteger) {
    return Int(val)
  } else if let val = val as? (any BinaryFloatingPoint) {
    return Int(val)
  } else if let val = val as? String {
    return Int(val.numbered, radix: 10)
  } else {
    return nil
  }
}
// any to double
public func a2d(_ val: Any?) -> Double? {
  if let val = val as? (any BinaryInteger) {
    return Double(val)
  } else if let val = val as? (any BinaryFloatingPoint) {
    return Double(val)
  } else if let val = val as? String {
    return Double(val.numbered)
  } else {
    return nil
  }
}

public extension FixedWidthInteger {
  @discardableResult
  mutating func inc() -> Self {
    if self == Self.max {
      self = Self.min
    } else {
      self += 1
    }
    return self
  }
  @discardableResult
  mutating func dec() -> Self {
    if self == Self.min {
      self = Self.max
    } else {
      self -= 1
    }
    return self
  }
}
