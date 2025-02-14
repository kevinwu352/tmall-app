//
//  UserModel.swift
//  ModCommon
//
//  Created by Kevin Wu on 2022/1/1.
//

import UIKit
import SwiftyJSON

public struct UserModel: AnyModel, Codable {

  public var uid = ""
  public var name = ""
  public var age = 0
  public var token = ""

  public var homeDir: String {
    uid
  }

  public init() { }

  public init(any: Any?) { }

}
