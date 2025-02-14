//
//  Module.swift
//  ModUserCenter
//
//  Created by Kevin Wu on 2022/1/1.
//

import UIKit
import ModCommon

public class UserCenterModule {

  public static let shared = UserCenterModule()

  public let priority = 11

  public func setup() {
    print("[userc] 11")

    Route.register(UserCenterViewController.self, Route.UserCenter.name)
  }

}

extension UserCenterModule: UserCenterService {

  public var list: [String] {
    return ["in user center"]
  }

}
