//
//  AppOptions.swift
//  ModCommon
//
//  Created by Kevin Wu on 2022/1/1.
//

import UIKit

public class AppOptions {

  public static let shared: AppOptions = {
    let ret = AppOptions(pathmk("/options", nil))
    return ret
  }()

  init(_ path: String) {
    defaults = Defaults(path)
    load()
  }
  public private(set) var defaults: Defaults {
    didSet { load() }
  }

  // =============================================================================


  func load() {
    //currencyList = defaults.getObject("currency_list") ?? []
  }


  //@Setted public var currencyList: [CurrencyModel] = [] {
  //  willSet { defaults.setObject(newValue, "currency_list") }
  //}

}
