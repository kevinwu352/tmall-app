//
//  ActorViewController.swift
//  contest
//
//  Created by Kevin Wu on 1/26/26.
//

import UIKit


@globalActor
actor MyActor {
  static let shared = MyActor()
}


// ================================================================================
// Actor 是引用类型，无法被继承
// let 属性在外部被访问时，不用 await，因为不可变
// var 属性只能在内部被修改，在外部被修改时会有警告。以前好像是错误，现在变警告了
//
// 虽然 Actor 有重入问题，但不要想着用锁去解决，不推荐用锁


// ================================================================================
// 教程说，大部分时间 Actor 的工作都运行在自己的 executor 上，但初始化时 executor 还没准备好
// 所以开发组决定：Actor 的构造器能是 async 的，当所有成员赋值以后，移动到自己的 executor 上运行
// 据说这功能还没开发完成，下面两个 print 可能在不同的线程运行，这里也有 actor hop
// 下例子没有编译错误，这功能估计是已经开发完成了
actor AsyncActor {
  var name: String
  init(name: String) async {
    print(name)
    self.name = name
    print(name)
  }
}


// ================================================================================
// actor hopping 就是 actor 跳跃，在 actor 之间切换执行
//
// 非主任务运行在一个协作线程池，在这里面切换性能开销比较小
// 但如果在主和线程池间切换，会切换环境，开销比较大
//
// 下面的例子中：DataModel 在主，database 不在，所以会切换 100 次
// 解决方案是：把 id 数组传给它，让它内部做 100 次，最终只切换一次
// @MainActor
// class DataModel {
//   var users = [User]()
//   var database = Database() // 这是一个 actor
//   func loadUsers() async { // 这里运行在主
//     for i in 1...100 {
//       let user = await database.loadUser(id: i) // 这里跳跃到非主
//       users.append(user)
//     }
//   }
// }


// ================================================================================
// struct ContentView: View {
//   var body: some View {
//     VStack {
//       Text("+++")
//     }
//     .onAppear {
//       Task { MainActor.assertIsolated() } // 通过
//       // Task.detached { MainActor.assertIsolated() } // 失败
//
//       // Task { MyActor.assertIsolated() } // 失败
//       // Task.detached { MyActor.assertIsolated() } // 失败
//
//       Task { @MyActor in MyActor.assertIsolated() } // 通过
//       Task.detached { @MyActor in MyActor.assertIsolated() } // 通过
//     }
//   }
// }


class ActorViewController: UIViewController {

  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesEnded(touches, with: event)
    Task {
    }
  }
}
