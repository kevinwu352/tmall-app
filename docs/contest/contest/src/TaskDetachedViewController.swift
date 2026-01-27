//
//  TaskDetachedViewController.swift
//  contest
//
//  Created by Kevin Wu on 1/26/26.
//

import UIKit

// Task 继承调用者的 优先级/task local value/actor context，Task.detached 不继承
//   在一个 Task 里创建另一个 Task，新的 Task 拥有相同优先级
//   在一个 Actor 里用 Task.detached 创建 Task，新的 Task 访问 Actor 的函数要加 await
// 教程建议不要使用 Task.detached，不要学这东西，只有当 async let 和 task 无法解决问题时，才考虑用
actor DetachedActor {
  func login() {
    Task.detached {
      // 因为是 Task.detached，所以这里必须加 await，否则会编译错误
      if await self.authenticate(user: "taytay89", password: "n3wy0rk") {
        print("Successfully logged in.")
      } else {
        print("Sorry, something went wrong.")
      }
    }
  }
  func authenticate(user: String, password: String) -> Bool {
    return true
  }
}


// Main actor-isolated property 'name' can not be mutated from a nonisolated context
// 注：misc 那边讲 await 时提到 @State 能在其它线程更新，因为 @State 有特殊处理，这里又是咋回事呢？
// struct ContentView: View {
//   @State private var name = "Anonymous"
//   var body: some View {
//     VStack {
//       Text("Hello, \(name)!")
//       Button("Authenticate") {
//         Task.detached {            <= 如果这里用 Task.detached 会报上面那行警告
//           name = "Taylor"
//         }
//       }
//     }
//   }
// }


// Main actor-isolated property 'model' cannot be accessed from outside of the actor
// @Observable
// class ViewModel {
//   var name = "Anonymous"
// }
// struct ContentView: View {
//   @State private var model = ViewModel()
//   var body: some View {
//     VStack {
//       Text("Hello, \(model.name)!")
//       Button("Authenticate") {
//         Task.detached {            <= 如果这里用 Task.detached 直接编译错误
//           model.name = "Taylor"
//         }
//       }
//     }
//   }
// }


// taskDoWork1 先把 1 做完，再做 2
// taskDoWork2 的打印结果是交错的
// 但 全局函数 和 类成员函数 有区别
//   全局函数时，taskDoWork1 也是交错的
// 但经过我的试验，我 9.9 成肯定这和 Build Settings 里的默认 Actor 有关
// 如果默认是 MainActor，Task 和 Task.detached 的行为就正常了，前者是做完再做下一个，后才是交错
func taskDoWork1() {
  Task {
    for i in 1...10_000 {
      print("In Task 1: \(i)")
    }
  }
  Task {
    for i in 1...10_000 {
      print("In Task 2: \(i)")
    }
  }
}
func taskDoWork2() {
  Task.detached {
    for i in 1...10_000 {
      print("In Task 1: \(i)")
    }
  }
  Task.detached {
    for i in 1...10_000 {
      print("In Task 2: \(i)")
    }
  }
}


class TaskDetachedViewController: UIViewController {

  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesEnded(touches, with: event)
    taskDoWork1()
  }

}
