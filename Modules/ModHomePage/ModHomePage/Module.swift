//
//  Module.swift
//  ModHomePage
//
//  Created by Kevin Wu on 2022/1/1.
//

import UIKit
import ModCommon

public class HomePageModule {

  public static let shared = HomePageModule()

  public let priority = 14

  public func setup() {
    print("[homep] 14")

    Route.register(HomePageViewController.self, Route.HomePage.name)
  }

}

extension HomePageModule: HomePageService {

  public var list: [String] {
    ["in home page"]
  }

}
