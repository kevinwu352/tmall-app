//
//  Number.swift
//  ModCommon
//
//  Created by Kevin Wu on 2022/1/1.
//

import UIKit

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


public extension BinaryInteger {

  func dhms(_ trim: Bool) -> [(Int,String)] {
    var list = [
      (  self.int / 86400              , "d"),
      ( (self.int % 86400) / 3600      , "h"),
      (((self.int % 86400) % 3600) / 60, "m"),
      (((self.int % 86400) % 3600) % 60, "s"),
    ]
    if trim {
      while list.first?.0 == 0 && list.count > 1 {
        list.removeFirst()
      }
    }
    return list
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
