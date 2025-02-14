//
//  AppCache.swift
//  ModCommon
//
//  Created by Kevin Wu on 2022/1/1.
//

import UIKit

public struct AppCache {

  // MARK: Memory Cache

  public static let inMemory: MemoryCache<String,String> = {
    let ret = MemoryCache<String,String>(.seconds(60*10), 0, 0)
    ret.setup(nil)
    return ret
  }()


  // MARK: Disk Cache

  public static let onDisk: DiskCache<String,String> = {
    let ret = DiskCache<String,String>("strche", .seconds(60*10), 0)
    ret.setup(nil)
    return ret
  }()

}
