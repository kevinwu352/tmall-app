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

}
