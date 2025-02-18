//
//  Modhub.swift
//  ModCommon
//
//  Created by Kevin Wu on 2022/1/1.
//

import UIKit

// Modhub.register(XXXService.self, instance)
//
// let module = Modhub.module(XXXService.self)

public let HomePageMod = Modhub.module(HomePageService.self)!
public let HuaSuanMod = Modhub.module(HuaSuanService.self)!
public let ShopCarMod = Modhub.module(ShopCarService.self)!
public let UserCenterMod = Modhub.module(UserCenterService.self)!


public protocol Modulable: AnyObject {
  var priority: Int { get }
  func setup()
}

public struct Modhub {

  static var modules: [String:Modulable] = [:]

  public static func register<S>(_ service: S.Type, _ module: S) {
    let key = String(describing: service)
    modules[key] = module as? Modulable
  }

  public static func module<S>(_ service: S.Type) -> S? {
    let key = String(describing: service)
    return modules[key] as? S
  }

  public static func setup() {
    modules.values
      .sorted { $0.priority > $1.priority }
      .forEach { $0.setup() }
  }

}
