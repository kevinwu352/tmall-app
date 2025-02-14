//
//  CommonConfiger.swift
//  ModCommon
//
//  Created by Kevin Wu on 2022/1/1.
//

import UIKit

public class CommonConfiger: BaseObject {

  public static let shared = CommonConfiger()

  public func beforeCreateWindow() {
    // Modular
    Route.register(WebViewController.self, "web")

    // Common
    _ = Defaults.shared

    _ = AccountManager.shared

    _ = AppOptions.shared
    _ = UserOptions.shared

    _ = AppCache.inMemory
    _ = AppCache.onDisk
    _ = UserCache.inMemory
    _ = UserCache.onDisk

    _ = MainHTTP.shared
    _ = TigerHTTP.shared

    NetworkMonitor.shared.startMonitoring()

    // UI
    _ = ThemeManager.shared
    _ = LanguageManager.shared
  }
  public func afterCreateWindow() {
  }

  public func beforeLaunch(_ networkOk: Bool) {
  }
  public func afterLaunch(_ networkOk: Bool) {
  }

}
