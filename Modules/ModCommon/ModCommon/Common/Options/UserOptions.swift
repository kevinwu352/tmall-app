//
//  UserOptions.swift
//  ModCommon
//
//  Created by Kevin Wu on 2022/1/1.
//

import UIKit

public class UserOptions {

  public static let shared: UserOptions = {
    let ret = UserOptions(pathmk("/options", HOME_DIR))
    AccountManager.shared.userHooks["01::user-options::shared"] = { [weak ret] in ret?.reloadUser($0) }
    return ret
  }()

  init(_ path: String) {
    defaults = Defaults(path)
    load()
  }
  public private(set) var defaults: Defaults {
    didSet { load() }
  }
  func reloadUser(_ user: UserModel?) {
    defaults = Defaults(pathmk("/options", user?.homeDir ?? HOME_SHARED))
  }

  func load() {
  }


}
