//
//  Module.swift
//  ModShopCar
//
//  Created by Kevin Wu on 2022/1/1.
//

import UIKit
import ModCommon

public class ShopCarModule {

  public static let shared = ShopCarModule()

  public let priority = 12

  public func setup() {
    print("[shopc] 12")

    Route.register(ShopCarViewController.self, Route.ShopCar.name)
  }

}

extension ShopCarModule: ShopCarService {

  public var list: [String] {
    return ["in shop car"]
  }

}
