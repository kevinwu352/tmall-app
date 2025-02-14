//
//  Module.swift
//  ModHuaSuan
//
//  Created by Kevin Wu on 2022/1/1.
//

import UIKit
import ModCommon

public class HuaSuanModule {

  public static let shared = HuaSuanModule()

  public let priority = 13

  public func setup() {
    print("[huasu] 13")

    Route.register(HuaSuanViewController.self, Route.HuaSuan.name)
  }

}

extension HuaSuanModule: HuaSuanService {

  public var list: [String] {
    ["in hua suan"]
  }

}
