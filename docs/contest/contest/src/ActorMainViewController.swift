//
//  ActorMainViewController.swift
//  contest
//
//  Created by Kevin Wu on 1/28/26.
//

import UIKit

// let result = await MainActor.run {
//   print("main actor")
//   return 42 // 能返回一个值
// }


// ================================================================================
// 如果当前正在主线程
//   await MainActor.run() 是马上执行，其实，它前面有 await，肯定得阻塞住这里，打印出 2
//   Task { @MainActor in } 是等下个 runloop
//   Task { await MainActor.run {} } 效果同上，但不够简约
@MyActor
class ActorRunSequence {
  func runTest() async {
    print("1")
    await MainActor.run {
      print("2")
      Task { @MainActor in
        print("3")
      }
      print("4")
    }
    print("5")
  }
}
// @MainActor: 1 2 4 5 3
// @MyActor:   1 2 4 3 5


// ================================================================================
// 以下代码要建一个 SwiftUI 工程，注释掉 App 声明，然后把文件名改成 main.swift
//
// 顶层环境在 MainActor，不管 SWIFT_DEFAULT_ACTOR_ISOLATION
// print("111")
// MainActor.assertIsolated()
// print("222")
//
// Task 继承了父的，所以也在 MainActor
// Task {
//   print("333")
//   MainActor.assertIsolated()
//   print("444")
// }
//
// 但方法内部的 Task 不在 MainActor
// Task 会继承父的，但方法没继承父的，方法内部的环境非主
// 注：这里规则好像改了
// 注：其实这三个研究也没多大意义，谁会在意顶层环境在哪？
//     平时我们肯定都是有 actor 环境的，这些代码都是在顶层执行的，我们不会在所有函数和类外面写 print()
//@MyActor // 加上这行的话，下面两个肯定会异常
// func could_be_anywhere() async {
//   MainActor.assertIsolated() // 这里以前应该是会异常的，现在不会了
//   let result = await MainActor.run {
//     print("main actor")
//     return 1
//   }
//   MainActor.assertIsolated() // 这里以前应该是会异常的，现在不会了
//   print(result)
// }
// await could_be_anywhere()



class ActorMainViewController: UIViewController {

  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesEnded(touches, with: event)
    Task {
//      await actor_run_sequence()
    }
  }

  // ================================================================================
  func actor_run_sequence() async {
    let obj = ActorRunSequence()
    await obj.runTest()
  }

}
