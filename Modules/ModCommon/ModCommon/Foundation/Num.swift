//
//  Num.swift
//  ModCommon
//
//  Created by Kevin Wu on 2022/1/1.
//

import UIKit

// 0.
// 3333333333
// 3333333333
// 3333333333
// 33333333

// print( Num(1) / "3" )
// 0.33333333333333333333333333333333333333
//
// print( Num(1/3.0) )
// 0.333333333333333248

public struct Num: CustomStringConvertible {

  public static let nan = Num(Decimal.nan)
  public static let zero = Num(Decimal.zero)
  public static let one = Num(Decimal(1))


  public let raw: Decimal

  public init(_ value: Any?) {
    let dcm: Decimal
    if let value = value as? (any BinaryInteger) {
      dcm = Decimal(Int(value))
    } else if let value = value as? (any BinaryFloatingPoint) {
      dcm = Decimal(Double(value))
    } else if let value = value as? String {
      dcm = Decimal(string: value.numbered, locale: nil) ?? .nan
    } else if let value = value as? Decimal {
      dcm = value
    } else if let value = value as? Num {
      dcm = value.raw
    } else {
      dcm = .nan
    }
    raw = dcm.isFinite ? dcm : .nan
  }

  public var isFinite: Bool {
    raw.isFinite
  }
  public var finited: Self? {
    raw.isFinite ? self : nil
  }


  public var int: Int? {
    guard let dcm = finited?.raw else { return nil }
    return Int((dcm as NSDecimalNumber).doubleValue)
  }
  public var intv: Int {
    int ?? 0
  }

  public var dbl: Double? {
    guard let dcm = finited?.raw else { return nil }
    return (dcm as NSDecimalNumber).doubleValue
  }
  public var dblv: Double {
    dbl ?? 0.0
  }

  public var str: String? {
    format(.original)
  }
  public var strv: String {
    str ?? ""
  }

  // String(describing:)
  // print(_:)
  public var description: String {
    format(.original) ?? "[NaN]"
  }


  public var l: Bool {
    raw.isFinite ? raw < .zero : false
  }
  public var le: Bool {
    raw.isFinite ? raw <= .zero : false
  }
  public var e: Bool {
    raw.isFinite ? raw == .zero : false
  }
  public var ge: Bool {
    raw.isFinite ? raw >= .zero : false
  }
  public var g: Bool {
    raw.isFinite ? raw > .zero : false
  }


  public enum Format {
    case original
    case scale(_ places: Int, _ mode: Decimal.RoundingMode)
    case pad(_ places: Int, _ mode: Decimal.RoundingMode) // pad 0
    public func str(_ dcm: Decimal) -> String {
      switch self {
      case .original:
        return dcm.str(nil, nil)
      case let .scale(places, mode):
        return dcm.str(places, mode)
      case let .pad(places, mode):
        return dcm.str(places, mode).zeroPadded(places)
      }
    }
  }
  public func format(_ format: Format) -> String? {
    raw.isFinite ? format.str(raw) : nil
  }

}

extension Num: Equatable, Hashable, Comparable {

  public static func < (lhs: Num, rhs: Num) -> Bool {
    lhs.isFinite && rhs.isFinite && lhs.raw < rhs.raw
  }

  public static func <= (lhs: Num, rhs: Num) -> Bool {
    lhs.isFinite && rhs.isFinite && lhs.raw <= rhs.raw
  }

  public static func > (lhs: Num, rhs: Num) -> Bool {
    lhs.isFinite && rhs.isFinite && lhs.raw > rhs.raw
  }

  public static func >= (lhs: Num, rhs: Num) -> Bool {
    lhs.isFinite && rhs.isFinite && lhs.raw >= rhs.raw
  }

}

public extension Num {

  static func + (lhs: Num, rhs: @autoclosure ()->Any?) -> Num { // CLOS
    if let l = lhs.finited?.raw,
       let r = Num(rhs()).finited?.raw
    {
      return Num(l + r)
    }
    return .nan
  }

  static func - (lhs: Num, rhs: @autoclosure ()->Any?) -> Num { // CLOS
    if let l = lhs.finited?.raw,
       let r = Num(rhs()).finited?.raw
    {
      return Num(l - r)
    }
    return .nan
  }

  static func * (lhs: Num, rhs: @autoclosure ()->Any?) -> Num { // CLOS
    if let l = lhs.finited?.raw,
       let r = Num(rhs()).finited?.raw
    {
      return Num(l * r)
    }
    return .nan
  }

  static func / (lhs: Num, rhs: @autoclosure ()->Any?) -> Num { // CLOS
    if let l = lhs.finited?.raw,
       let r = Num(rhs()).finited?.raw
    {
      return Num(l / r)
    }
    return .nan
  }

}


public extension Num {

  // 四舍五入，不管正负
  //  1.24=> 1.2,  1.25=> 1.3
  // -1.24=>-1.2, -1.25=>-1.3
  func scalePlain(_ places: Any?) -> String? {
    guard let p = Num(places).int else { return format(.original) }
    return format(.scale(p, .plain))
  }
  // x 轴往左
  //  1.24=> 1.2
  // -1.24=>-1.3
  func scaleDown(_ places: Any?) -> String? {
    guard let p = Num(places).int else { return format(.original) }
    return format(.scale(p, .down))
  }
  // x 轴往右
  //  1.24=> 1.3
  // -1.24=>-1.2
  func scaleUp(_ places: Any?) -> String? {
    guard let p = Num(places).int else { return format(.original) }
    return format(.scale(p, .up))
  }
  // 后面非 5 时，四舍六入
  //  1.24=> 1.2,  1.26=> 1.3
  // -1.24=>-1.2, -1.26=>-1.3
  // 后面是 5 时，5 后无数，向偶数靠近
  //  1.25=> 1.2,  1.35=> 1.4
  // -1.25=>-1.2, -1.35=>-1.4
  // 后面是 5 时，5 后有数，直接加一
  //  1.251=> 1.3,  1.351=> 1.4
  // -1.251=>-1.3, -1.351=>-1.4
  func scaleBankers(_ places: Any?) -> String? {
    guard let p = Num(places).int else { return format(.original) }
    return format(.scale(p, .bankers))
  }
  // x 轴内聚
  func scaleInner(_ places: Any?) -> String? {
    guard let p = Num(places).int else { return format(.original) }
    return format(.scale(p, raw >= .zero ? .down : .up))
  }
  // x 轴外放
  func scaleOuter(_ places: Any?) -> String? {
    guard let p = Num(places).int else { return format(.original) }
    return format(.scale(p, raw >= .zero ? .up : .down))
  }


  func padPlain(_ places: Any?) -> String? {
    guard let p = Num(places).int else { return format(.original) }
    return format(.pad(p, .plain))
  }
  func padDown(_ places: Any?) -> String? {
    guard let p = Num(places).int else { return format(.original) }
    return format(.pad(p, .down))
  }
  func padUp(_ places: Any?) -> String? {
    guard let p = Num(places).int else { return format(.original) }
    return format(.pad(p, .up))
  }
  func padBankers(_ places: Any?) -> String? {
    guard let p = Num(places).int else { return format(.original) }
    return format(.pad(p, .bankers))
  }
  func padInner(_ places: Any?) -> String? {
    guard let p = Num(places).int else { return format(.original) }
    return format(.pad(p, raw >= .zero ? .down : .up))
  }
  func padOuter(_ places: Any?) -> String? {
    guard let p = Num(places).int else { return format(.original) }
    return format(.pad(p, raw >= .zero ? .up : .down))
  }

}


public extension Decimal {
  func str(_ places: Int?, _ mode: Decimal.RoundingMode?) -> String {
    var res: Decimal = .nan
    var raw = self
    if let places = places, let mode = mode {
      NSDecimalRound(&res, &raw, places, mode)
    } else {
      res = raw
    }
    let str = NSDecimalString(&res, nil)
    return str
  }
}
