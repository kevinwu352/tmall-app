//
//  AccountManager.swift
//  ModCommon
//
//  Created by Kevin Wu on 2022/1/1.
//

import UIKit
import Combine

public var LOGINED: Bool { AccountManager.shared.hasAccountLogined }
public var LOGINED_USERNAME: String? { AccountManager.shared.username }
public var LOGINED_USER: UserModel? { AccountManager.shared.user }

public let HOME_SHARED = "shared"
public var HOME_DIR: String { AccountManager.shared.user?.homeDir ?? HOME_SHARED }

public extension NSNotification.Name {
  static let AccountDidLogin = NSNotification.Name("AccountDidLoginNotification")
  static let AccountDidLogout = NSNotification.Name("AccountDidLogoutNotification")
  static let AccountDidChange = NSNotification.Name("AccountDidChangeNotification")
}

public class AccountManager {

  public static let shared = AccountManager()

  @Setted public private(set) var username: String?
  @Setted public private(set) var user: UserModel?

  // $user 难以控制触发的顺序，所以：
  // a)内部底层一些重要工作由 hook 先触发
  // b)其它只关心内容本身，或者说与顺序无关的工作，用 $user 触发
  //
  // 1::user-options::shared
  // 2::user-cache::in-memory
  // 2::user-cache::on-disk
  // 3::main-http::manager
  public var userHooks: [String:(UserModel?)->Void] = [:] // CLOS
  func invokeHooks(_ user: UserModel?) {
    userHooks.enumerated()
      .sorted { $0.element.key < $1.element.key }
      .forEach {
        print("[Commo] invoke user hook: \($0.element.key)")
        $0.element.value(user)
      }
  }


  init() {
    path_create_directory(pathmk("", HOME_SHARED))

    if let lastUsername = lastUsername, lastUsername.notEmpty,
       let lastUser = UserModel.fromFile(pathmk("/user", lastUsername))
    {
      username = lastUsername
      user = lastUser
    } else {
      username = nil
      user = nil
    }
  }


  // MARK: Login & Logout

  public var lastUsername: String? {
    get { Defaults.shared.getString("last_username") }
    set { Defaults.shared.setString(newValue, "last_username") }
  }

  public func addLogin(_ username: String, _ password: String?, _ user: UserModel) {
    guard username.notEmpty else { return }
    path_create_directory(pathmk("", username))
    addCurrentAccount(username, user)
    addLoginedAccount(username, password)
    lastUsername = username
    NotificationCenter.default.post(name: .AccountDidLogin, object: username)
    NotificationCenter.default.post(name: .AccountDidChange, object: username)
  }
  public func removeLogin() {
    guard let username = username else { return }
    lastUsername = nil
    removeLoginedAccount(username)
    removeCurrentAccount()
    path_delete(pathmk("", username))
    NotificationCenter.default.post(name: .AccountDidLogout, object: username)
    NotificationCenter.default.post(name: .AccountDidChange, object: username)
  }


  // MARK: Current Account

  public var hasAccountLogined: Bool {
    username != nil && user != nil
  }
  public func saveCurrentAccount() {
    guard let username = username else { return }
    guard let user = user else { return }
    user.toFile(pathmk("/user", username))
  }
  func addCurrentAccount(_ username: String, _ user: UserModel) {
    invokeHooks(user)
    self.username = username
    self.user = user
    saveCurrentAccount()
  }
  func removeCurrentAccount() {
    invokeHooks(nil)
    username = nil
    user = nil
  }


  // MARK: Logined Accounts

  public struct Account: Codable {
    public var username: String
    public var password: String?
  }
  public var loginedAccounts: [Account] {
    get { Defaults.shared.getObject("logined_accounts") ?? [] }
    set { Defaults.shared.setObject(newValue, "logined_accounts") }
  }
  public func addLoginedAccount(_ username: String, _ password: String?) {
    guard username.notEmpty else { return }

    var accounts = loginedAccounts
    accounts.removeAll { $0.username == username }
    accounts.insert(Account(username: username, password: password), at: 0)
    loginedAccounts = accounts
  }
  public func removeLoginedAccount(_ username: String) {
    guard username.notEmpty else { return }

    var accounts = loginedAccounts
    accounts.removeAll { $0.username == username }
    loginedAccounts = accounts
  }
  public func removeLoginedPassword(_ username: String) {
    guard username.notEmpty else { return }

    var accounts = loginedAccounts
    if let index = accounts.firstIndex(where: { $0.username == username }) {
      accounts[index].password = nil
    }
    loginedAccounts = accounts
  }

}
