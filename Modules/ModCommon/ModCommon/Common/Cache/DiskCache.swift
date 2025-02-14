//
//  DiskCache.swift
//  ModCommon
//
//  Created by Kevin Wu on 2022/1/1.
//

import UIKit
import Cache

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
                            directory: URL(fileURLWithPath: pathmk("/Caches", dir)),
                            protectionType: nil)
    storage = try? DiskStorage<Key,Value>(config: config,
                                          fileManager: FileManager.default,
                                          transformer: transformer)
  }

  public func reloadUser(_ user: UserModel?) {
    setup(user?.homeDir ?? HOME_SHARED)
  }
}
