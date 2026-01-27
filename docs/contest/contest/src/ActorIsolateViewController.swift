//
//  ActorIsolateViewController.swift
//  contest
//
//  Created by Kevin Wu on 1/27/26.
//

import UIKit

// ================================================================================
actor BankAccount {
  let accountNumber: Int
  var balance: Double
  init(accountNumber: Int, balance: Double) {
    self.accountNumber = accountNumber
    self.balance = balance
  }
}
// isolated 关键字能把 deposit 函数归属到某个 Actor，让函数内部能访问和修改 BankAccount 内部的值
// 不能有两个 isolated 参数
func deposit(amount: Double, to account: isolated BankAccount) {
  assert(amount >= 0)
  account.balance = account.balance + amount
}
// 使用的时候，虽然 deposit 不是 async 函数，但是必须添加 await
// 我的理解：既然 deposit 已经归属于 BankAccount 了，那么就把它当成 BankAccount 的成员函数得了


// ================================================================================
// 一个被全局 actor 修饰的类型如果不写自定义的 init，那么它能在任何 actor 环境内被初始化
// 如果写了自定义的 init，这个 init 也限定了环境，就算它不需要参数，也不能在其它 actor 上被初始化了
// 试一下？如果把这里的 init 取消注释，就会编译失败。添加 await 能成功
@MyActor
class IsolatedUser {
  init(name: String = "") {
    self.name = name
  }
  var name = "kv"
}
@MainActor
class MainUser {
  init(name: String = "") {
    self.name = name
  }
  var name = "bb"
}


// ================================================================================
// @isolated(any)


class ActorIsolateViewController: UIViewController {

  // ================================================================================
  func bank_account_deposit() async {
    let ba = BankAccount(accountNumber: 1, balance: 2)
    await deposit(amount: 2, to: ba)
  }

  // ================================================================================
  func isolated_user() async {
    // let user = IsolatedUser()
    let user = await IsolatedUser()
    print(user)
  }

  // ================================================================================
  // 这里的 @isolated(any) 表示：调用的时候在 in 前面传的哪个 actor，就在哪个 actor 上面运行这个 closure
  func isolated_closure(_ h: @escaping @Sendable @isolated(any) () -> Void) {
  }
  func call_isolated_closure() {
    isolated_closure { @MyActor in
      // IsolatedUser 本来是属于 MyActor 的，在这里能被初始化，说明此时的环境真的在 @MyActor 上
      let user1 = IsolatedUser()
      print(user1)
      user1.name = "xx" // 这里无警告
      // 这里有警告说
      // Call to main actor-isolated initializer 'init(name:)' in a synchronous global actor 'MyActor'-isolated context
      let user2 = MainUser()
      print(user2)
      user2.name = "yy" // 这里有警告
    }
  }

}


// ================================================================================
// 如果你百分百确定是安全的，你可以用 nonisolated(unsafe)，告诉编译器，这是有意的，这不会造成数据竞争
// with a global variable
nonisolated(unsafe) var myVariable = UUID()
// or as a static property
struct CharacterMaker {
  nonisolated(unsafe) static var myVariable = UUID()
}
// 这特性没用过


// ================================================================================
// 6.2 新特性：无环境对象上的 同步异步 方法都会在当前环境执行
class NetworkingClient {
  func loadUsers1() async -> [Int] {
    return []
  }
  func loadUsers2() -> [Int] {
    []
  }
}
@MainActor
class ContentViewModel {
  let network = NetworkingClient()
  func doit() async {
    _ = await network.loadUsers1() // 6.2 以前，这里要报错的
    _ = network.loadUsers2()
  }
}
