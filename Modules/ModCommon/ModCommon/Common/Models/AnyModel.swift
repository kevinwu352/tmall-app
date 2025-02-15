//
//  AnyModel.swift
//  ModCommon
//
//  Created by Kevin Wu on 2022/1/1.
//

import UIKit
import SwiftyJSON

public extension JSON {
  init(any: Any?) { // FUNC
    if let val = any as? JSON {
      self.init(val.rawValue)
    } else if let val = any as? String {
      self.init(parseJSON: val)
    } else {
      self.init(any as Any) // data or dict
    }
  }
}


/*
 public struct FoobarModel: AnyModel {
   var name: String?
   var age: Int?

   public init() { }

   public init(any: Any?) {
     let json = JSON(any: any)
     name = json["name"].string
     age = json["age"].int
   }
 }
 */

public protocol AnyModel {
  init(any: Any?) // FUNC
}

extension Array: AnyModel where Element: AnyModel {
  public init(any: Any?) {
    let json = JSON(any: any)
    self.init(json.arrayValue.map({ Element(any: $0) }))
  }
}

extension Bool: AnyModel {
  public init(any: Any?) {
    let json = JSON(any: any)
    self.init(json.boolValue)
  }
}

extension Int: AnyModel {
  public init(any: Any?) {
    let json = JSON(any: any)
    self.init(json.intValue)
  }
}

extension Double: AnyModel {
  public init(any: Any?) {
    let json = JSON(any: any)
    self.init(json.doubleValue)
  }
}

extension String: AnyModel {
  public init(any: Any?) {
    let json = JSON(any: any)
    self.init(json.stringValue)
  }
}
