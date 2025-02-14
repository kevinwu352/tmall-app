//
//  UserCache.swift
//  ModCommon
//
//  Created by Kevin Wu on 2022/1/1.
//

import UIKit

public struct UserCache {

  // MARK: Memory Cache

  public static let inMemory: MemoryCache<String,String> = {
    let ret = MemoryCache<String,String>(.seconds(60*10), 0, 0)
    ret.setup(HOME_DIR)
    AccountManager.shared.userHooks["02::user-cache::in-memory"] = { [weak ret] in ret?.reloadUser($0) }
    return ret
  }()


  // MARK: Disk Cache

  public static let onDisk: DiskCache<String,String> = {
    let ret = DiskCache<String,String>("strche", .seconds(60*10), 0)
    ret.setup(HOME_DIR)
    AccountManager.shared.userHooks["02::user-cache::on-disk"] = { [weak ret] in ret?.reloadUser($0) }
    return ret
  }()

}
