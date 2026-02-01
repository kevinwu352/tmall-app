//
//  AsyncLetViewController.swift
//  contest
//
//  Created by Kevin Wu on 1/26/26.
//

import UIKit

// 这种写法好新颖，有什么用呢？
// async let user = User(name: "twostraws")
//
// async var 会导致一种困惑，所以不支持这种写法
//   马上赋新值，该不该取消异常获取值的操作？
//   如果不取消，新值到来时，该不该赋给变量？
//   既然直接设了值，await 还有没有必要呢？
// async var username = fetchUsername()
// username = "Justin Bieber"
// print("Username is \(username)")


class AsyncLetViewController: UIViewController {

  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesEnded(touches, with: event)
    Task {
      await async_let()
    }
  }

  // 本例中，前两个有 await，而 getBlah 没有
  // age2 先完成，然后是 name1，然后函数就结束了，导致 blah 任务取消
  // 如何看出来 blah 是取消了？
  // 因为 blah 等的时间最长 10s，打印 end1 时，马上打印了 Person 实例，马上打印了 end3
  // end3 应该会非常久的，但它的 Task.sleep 因取消而异常退出，但被 try? 掩盖了，所以，马上打印了 end3
  //
  // Donny Wals 说，父函数 async_let() 因为没 await blah 这个任务，所以会导致 blah 任务取消
  // 虽然 blah 取消了，async_let() 函数也会等 blah 退出
  // 这里的 blah 里用的是 sleep，它响应取消非常快，所以看不出来什么效果
  // 如果是另外一个不及时响应取消的函数，或收到取消后继续做的函数，那 async_let() 就会接着等下去，等 blah 退出
  // 所以 async_let 因为没等 blah 的结果，导致 blah 取消，但是会等 blah 退出。不知如何验证？
  func async_let() async {
    print("begin")
    async let name = getName()
    async let age = getAge()
    // async let blah = getBlah()
    print("end") // begin 以后，马上就到这里，没有任何等待
    // 如果 name / age 抛出异常，上面不用 try，在这里 try await 并用 do-catch 包起来
    let p = await Person(name: name, age: age)
    print(p)
    // 也能这样等结果
    // return await (news, weather, hasUpdate)
  }
  func getName() async -> String {
    print("begin1")
    try? await Task.sleep(for: .seconds(5))
    print("end1")
    return "kevin"
  }
  func getAge() async -> Int {
    print("begin2")
    try? await Task.sleep(for: .seconds(2))
    print("end2")
    return 18
  }
  func getBlah() async -> String {
    print("begin3")
    try? await Task.sleep(for: .seconds(10))
    print("end3")
    return "asdf"
  }

  struct Person {
    let name: String
    let age: Int
  }

}
