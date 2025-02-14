//
//  AppConfiger.swift
//  TmallApp
//
//  Created by Kevin Wu on 2022/1/1.
//

import UIKit
import ModCommon

import ModHomePage
import ModHuaSuan
import ModShopCar
import ModUserCenter

class AppConfiger: BaseObject {

  static let shared = AppConfiger()

  func beforeCreateWindow() {
    CommonConfiger.shared.beforeCreateWindow()

    // Modular
    Modhub.register(HomePageService.self, HomePageModule.shared)
    Modhub.register(HuaSuanService.self, HuaSuanModule.shared)
    Modhub.register(ShopCarService.self, ShopCarModule.shared)
    Modhub.register(UserCenterService.self, UserCenterModule.shared)
    Modhub.setup()

    Navigator.segs = [.HomePage, .HuaSuan, .ShopCar, .UserCenter]
  }
  func afterCreateWindow() {
    CommonConfiger.shared.afterCreateWindow()
  }

  func beforeLaunch(_ networkOk: Bool) {
    CommonConfiger.shared.beforeLaunch(networkOk)
  }
  func afterLaunch(_ networkOk: Bool) {
    CommonConfiger.shared.afterLaunch(networkOk)
  }

}
