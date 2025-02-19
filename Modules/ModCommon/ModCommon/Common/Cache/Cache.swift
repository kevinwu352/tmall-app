//
//  Cache.swift
//  ModCommon
//
//  Created by Kevin Wu on 2022/1/1.
//

import UIKit
import Cache

public protocol Cachable {
  associatedtype Storage: StorageAware
  var storage: Storage? { get }
}

public extension Cachable {
  func setObject(_ object: Storage.Value, _ key: Storage.Key) {
    try? storage?.setObject(object, forKey: key, expiry: nil)
  }

  func object(_ key: Storage.Key) -> Storage.Value? {
    if let entry = try? storage?.entry(forKey: key), !entry.expiry.isExpired {
      return entry.object
    } else {
      return nil
    }
  }
  func existsObject(_ key: Storage.Key) -> Bool {
    object(key) != nil
  }

  func removeObject(_ key: Storage.Key) {
    try? storage?.removeObject(forKey: key)
  }
  func removeExpiredObjects() {
    try? storage?.removeExpiredObjects()
  }
  func removeAllObjects() {
    try? storage?.removeAll()
  }
}


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


public class DiskCache<Key: Hashable, Value>: BaseObject, Cachable {
  let name: String
  let expiry: Expiry
  let maxSize: UInt
  let transformer: Transformer<Value>

  public init(_ name: String,
              _ expiry: Expiry,
              _ maxSize: UInt
  ) where Value == Data {
    self.name = name
    self.expiry = expiry
    self.maxSize = maxSize
    self.transformer = TransformerFactory.forData()
    super.init()
  }

  public init(_ name: String,
              _ expiry: Expiry,
              _ maxSize: UInt
  ) where Value == UIImage {
    self.name = name
    self.expiry = expiry
    self.maxSize = maxSize
    self.transformer = TransformerFactory.forImage()
    super.init()
  }

  public init(_ name: String,
              _ expiry: Expiry,
              _ maxSize: UInt
  ) where Value: Codable {
    self.name = name
    self.expiry = expiry
    self.maxSize = maxSize
    self.transformer = TransformerFactory.forCodable(ofType: Value.self)
    super.init()
  }

  public private(set) var storage: DiskStorage<Key,Value>?

  public func setup(_ dir: String?) {
    let config = DiskConfig(name: name,
                            expiry: expiry,
                            maxSize: maxSize,
                            directory: pathmk("/Caches", dir).furl,
                            protectionType: nil)
    storage = try? DiskStorage<Key,Value>(config: config,
                                          fileManager: FileManager.default,
                                          transformer: transformer)
  }
  public func reloadUser(_ user: UserModel?) {
    setup(user?.homeDir ?? HOME_SHARED)
  }
}
