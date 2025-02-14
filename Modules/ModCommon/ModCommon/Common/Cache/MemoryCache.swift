//
//  MemoryCache.swift
//  ModCommon
//
//  Created by Kevin Wu on 2022/1/1.
//

import UIKit
import Cache

public class MemoryCache<Key: Hashable, Value>: BaseObject, Cachable {
  let expiry: Expiry
  let countLimit: UInt
  let totalCostLimit: UInt

  public init(_ expiry: Expiry,
              _ countLimit: UInt,
              _ totalCostLimit: UInt
  ) {
    self.expiry = expiry
    self.countLimit = countLimit
    self.totalCostLimit = totalCostLimit
    super.init()
  }

  public private(set) var storage: MemoryStorage<Key,Value>?


  public func setup(_ dir: String?) {
    let config = MemoryConfig(expiry: expiry,
                              countLimit: countLimit,
                              totalCostLimit: totalCostLimit)
    storage = MemoryStorage<Key,Value>(config: config)
  }

  public func reloadUser(_ user: UserModel?) {
    setup(user?.homeDir ?? HOME_SHARED)
  }
}
