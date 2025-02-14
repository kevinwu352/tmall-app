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
