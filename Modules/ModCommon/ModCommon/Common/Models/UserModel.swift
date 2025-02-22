//
//  UserModel.swift
//  ModCommon
//
//  Created by Kevin Wu on 2022/1/1.
//

import UIKit

public struct UserModel: AnyModel, Codable {

  public var uid: String?
  public var name: String?
  public var age: Int?
  public var token: String?

  public var homeDir: String? { uid }

  public init() { }

  public init(any: Any?) {
    // let json = JSON(any: any)
    // uid = json["uid"].string
    // name = json["name"].string
    // age = json["age"].int
    // token = json["token"].string
  }

}
