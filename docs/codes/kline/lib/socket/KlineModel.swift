//
//  KlineModel.swift
//  ModHomePage
//
//  Created by Kevin Wu on 2022/1/1.
//

import UIKit
import SwiftyJSON
import AppCommon

public struct KlineModel: AnyModel, Codable {
  public var symbol = ""
  public var interval = ""

  public var begin = 0
  public var end = 0
  public var ended = false

  public var open = ""
  public var high = ""
  public var low = ""
  public var close = ""

  public var volume = ""
  public var quantity = ""
  public var orders = 0

  public var isIncrease: Bool {
    if let open = open.dbl, let close = close.dbl, open < close {
      return true
    } else {
      return false
    }
  }
  public var isDecrease: Bool {
    if let open = open.dbl, let close = close.dbl, open > close {
      return true
    } else {
      return false
    }
  }
  public var isNeutral: Bool {
    if let open = open.dbl, let close = close.dbl, open == close {
      return true
    } else {
      return false
    }
  }


  public init() { }

  public init(any: Any?) {
    let json = JSON.fromAny(any)
    if json.array != nil {
      begin = json.array?.at(0)?.int ?? 0
      end = json.array?.at(6)?.int ?? 0
      ended = end <= Int(Date().timeIntervalSince1970 * 1000)

      open = json.array?.at(1)?.string ?? ""
      high = json.array?.at(2)?.string ?? ""
      low = json.array?.at(3)?.string ?? ""
      close = json.array?.at(4)?.string ?? ""

      volume = json.array?.at(5)?.string ?? ""
      quantity = json.array?.at(7)?.string ?? ""
      orders = json.array?.at(8)?.int ?? 0
    } else {
      symbol = json["s"].stringValue
      interval = json["i"].stringValue

      begin = json["t"].intValue
      end = json["T"].intValue
      ended = json["x"].boolValue

      open = json["o"].stringValue
      high = json["h"].stringValue
      low = json["l"].stringValue
      close = json["c"].stringValue

      volume = json["v"].stringValue
      quantity = json["q"].stringValue
      orders = json["n"].intValue
    }
  }
}
