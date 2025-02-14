//
//  Modhub.swift
//  ModCommon
//
//  Created by Kevin Wu on 2022/1/1.
//

import UIKit

// Modhub.register(XXXService.self, instance)
// let module = Modhub.module(XXXService.self)


public let MOD_HOME_PAGE = Modhub.module(HomePageService.self)
public let MOD_HUA_SUAN = Modhub.module(HuaSuanService.self)
public let MOD_SHOP_CAR = Modhub.module(ShopCarService.self)
public let MOD_USER_CENTER = Modhub.module(UserCenterService.self)


public protocol Modulable: AnyObject {
  var priority: Int { get }
  func setup()
}

public struct Modhub {

  static var modules: [String:Modulable] = [:]

  public static func register<S>(_ service: S.Type, _ module: S) {
    modules["\(service)"] = module as? Modulable
  }

  public static func module<S>(_ service: S.Type) -> S? {
    modules["\(service)"] as? S
  }

  public static func setup() {
    modules.values
      .sorted { $0.priority > $1.priority }
      .forEach { $0.setup() }
  }

}
