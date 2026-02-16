//
//  SendViewController.swift
//  contest
//
//  Created by Kevin Wu on 1/25/26.
//

import UIKit

class SomeClass { }

func sending_closure(_ closure: sending () -> Void) {
  closure()
}

func sendable_closure(_ closure: @Sendable () -> Void) {
  closure()
}


class SendViewController: UIViewController {

  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesEnded(touches, with: event)

  }

  // ================================================================================
  func send() {
    Task {
      let sc = SomeClass()

      // 用 sending 时，新建 sc，马上传给 sending 闭包，且后面再也不用 sc，那么不会报错
      //
      // 规则好像改了，就算马上 print(sc) 也不会报错了
       sending_closure {
         print(sc)
       }
      // print(sc) // 本来这行会导致编译错误的

      // 用 sendable 时，sc 是非 sendable 的，所以报错
      //
      // 规则好像改了，非 Sendable 的类实例，传递给 @Sendable 闭包，也不编译错误了
      // sendable_closure {
      //   print(sc)
      // }
      // print(sc) // 以前要不要这行都会报错

      // 我感觉：是 Build Settings 里的这一项改掉了，本来是 nonisolated，现在新建工程都是 MainActor
      // 所以，SomeClass 估计属于 MainActor，它也就变成 Sendable 了，上面那些也就不报错了
      // SWIFT_DEFAULT_ACTOR_ISOLATION = nonisolated

    }
  }

  // ================================================================================
  // 协议上面的 Sendable 会传染，实现此协议的类也必须是 Sendable 的，虽然不用明确写出来，但隐含了
  // 协议上面的 @MainActor 会传染，实现此协议的类也是属于 MainActor 的，虽然不用明确写出来，但隐含了
  func infection() {
    let work = WorkEntry()
    sendable_closure {
      print(work)
    }
    Task { @MyActor in
      // 1) JobEntry1 没有 init 方法，它能在 @MyActor 里被创建
      let job1 = JobEntry1()
      print(job1)
      // 2) JobEntry2 有 init 方法，它能在 @MyActor 里被创建
      let job2 = JobEntry2()
      print(job2)
      // 3) JobEntry3 属于 MainActor 没有 init 方法，它能在 @MyActor 里被创建
      let job3 = JobEntry3()
      print(job3)
      // 4) JobEntry4 属于 MainActor 有 init 方法，它不能在 @MyActor 里被创建
//      let job4 = JobEntry4()
//      print(job4)
    }
  }

}

protocol WorkModule: Sendable { // 如果去掉这里，会有跨区的警告，说明协议里的 Sendable 影响了使用此协议的实体
  var name: String { get }
}
final class WorkEntry: WorkModule {
  let name = ""
}

protocol JobModuleA {
  var name: String { get }
}
final class JobEntry1: JobModuleA {
  let name = ""
}
final class JobEntry2: JobModuleA {
  init() {
    name = "xx"
  }
  let name: String
}

@MainActor // 种种迹象表明，它的实现者必须要用在 MainActor 上
protocol JobModuleB {
  var name: String { get }
}
final class JobEntry3: JobModuleB {
  let name = ""
}
final class JobEntry4: JobModuleB {
  init() {
    name = "xx"
  }
  let name: String
}
