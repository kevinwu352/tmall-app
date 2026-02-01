//
//  TaskViewController.swift
//  contest
//
//  Created by Kevin Wu on 1/26/26.
//

import UIKit

// async 函数 / async let 背后都是 Task


// 睡 3-4 秒，不会低于 3 秒
// 记住：
//   1) Task.sleep 不会阻塞线程，线程可以做其它事情
//   2) sleep 期间被 cancel，会马上唤醒并结束，且抛出异常
// try await Task.sleep(for: .seconds(3), tolerance: .seconds(1))


// 教程说 Swift6 能通过 throws(LoadError) 在 task closure 里限制此 Task 抛出的异常类型，但不知道怎么写？


// 如果现在我有个非常长的任务，我可以用 Task.yield() 主动让出执行权，让系统有机会调度其它任务
// 但并非一定会切换到其它任务，比如，如果自己优先级是最高的，那么，还是自己运行


// Task.priority 默认是 nil，意思是让系统自己决定如何调度
//   如果是从一个 Task 创建的 Task，后者会继承前者的优先级
//   如果是从主线程创建出来的 Task，会拥有最高 .high 优先级
//   如果既不是从 Task 来，也不是从主线程来，那就是 nil
// 所以，通常不需要给 priority 传值，用默认的就好了，系统会正确处理的
//
// .high 用户正在积极等待其结果的任务
// .medium 用户并未积极等待其结果的任务
// .low 通常界面有个进度条的任务，比如拷贝文件
// .background 用户看不见的任务，比如生成搜索索引
//
// 有些函数并未在 Task 内，如果你用 Task.currentPriority 获取优先级，返回的是系统的一个值 .medium
//
// 把优先级提升当成一种彩头，系统给的甜头，系统帮我们优化了
// 我们平时写代码不用操作这些，也改不了。只要知道有这东西存在就行了
// 优先级提升一：高优先级 等 低优先级，低优先级的任务会提升
// @main
// struct App {
//   static func main() async throws {
//     // outerTask 优先级是高
//     let outerTask = Task(priority: .high) {
//       print("Outer: \(Task.currentPriority)") // .high
//       // innerTask 优先级是低
//       let innerTask = Task(priority: .low) {
//         print("Inner: \(Task.currentPriority)") // .low
//         try await Task.sleep(for: .seconds(1))
//         print("Inner: \(Task.currentPriority)") // .high
//       }
//       // 外部等内部，高优先级 等 低优先级，内部的优先级会提升
//       try await Task.sleep(for: .seconds(0.5))
//       _ = try await innerTask.value
//     }
//     _ = try await outerTask.value
//   }
// }
// 优先级提升二：低优先级任务运行于某 actor，此时高优先级任务入队了，低任务的优先级会提升


class TaskViewController: UIViewController {

  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesEnded(touches, with: event)
//    run_order()

    Task {
//      await return_value_2()
//      await cancel_task()
      await cancel_network()
    }
  }

  // ================================================================================
  func run_order() {
    print("111")
    Task {
      print("333")
    }
    print("222")
  }

  // ================================================================================
  // 获取 Task 返回值
  // 1) 读取 task.value
  // 如果不返回值，task.value 也能访问，不过 value 的类型是 ()，也就是 Void
  func return_value_1() async {
    // task 变量的类型会根据内部返回的值变化
    // 这里的类型是 Task<[Int], Never>
    // 如果内部抛出了异常，类型会变成 Task<[Int], any Error>
    let task = Task {
      print("111")
      try? await Task.sleep(for: .seconds(2.0))
      print("222")
      // throw Unicode.UTF8.ValidationError.Kind.truncatedScalar
      return [1,2,3]
    }
    print("begin")
    let list = await task.value
    print(list)
    // 如果内部抛出异常，得换成 try await task.value
    // do {
    //   let list = try await task.value
    //   print(list)
    // } catch {
    //   print("got \(error)")
    // }
  }
  // 2) 读取 task.result
  func return_value_2() async {
    let task = Task {
      print("111")
      try? await Task.sleep(for: .seconds(2.0))
      print("222")
      // throw Unicode.UTF8.ValidationError.Kind.truncatedScalar
      return [1,2,3]
    }
    print("begin")
    // 不管内部有没有抛出异常，都用 await task.result
    // 因为 result 可以包含两种情况，这里并未解开，所以不用 try
    let result = await task.result
    // print(result.get())
    switch result {
    case .success(let success):
      print("success \(success)")
    case .failure(let failure):
      print("failure \(failure)")
    }
  }

  // ================================================================================
  // 取消 Task 需要 Task 内部检查并自己决定，Task 可以不管这个 cancel 请求，继续想做多久做多久
  // 系统内部的某些功能会检查 cancel 并抛出异常，比如 sleep
  // TaskGroup 里某个任务异常了，会导致其它正在进行中的任务 cancel
  // SwiftUI 中，当视图消失后，.task() 里的任务会 cancel
  // 如果取消时需要做一些清理操作，用 Task.isCancelled 检查，因为 Task.checkCancellation 会直接异常退出
  func cancel_task() async {
    let task = Task { () -> String in
      print("begin")
      try await Task.sleep(for: .seconds(5))
      // 不会走到这里，因为 2s 后取消，sleep 里面就异常退出了
      // 但如果上面是 try?，它会掩盖 sleep 抛出的 取消异常，就能走到 111
      //   不过，马上是 checkCancellation，它会跳走，执行不到 end
      print("111")
      try Task.checkCancellation()
      print("end")
      return "Done"
    }
    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
      print("cancel")
      task.cancel()
    }
    do {
      // 1) 虽然产生了异常，但是 result 并未解开，所以能正常走完 final
      let result = await task.result
      print(result)
      // 但是加上这两句代码，解开了 result，抛出了异常，所以不能正常走完 final，而是跳转到 catch
      let val = try result.get()
      print(val)

      // 2) Task 产生异常，这里直接解开了值，所以不能正常走完 final，而是跳转到 catch
      let value = try await task.value
      print(value)

      print("final")
    } catch {
      print("task was cancelled")
    }
  }
  // URLSession 的请求和 sleep 一样，也会内部检查 cancel
  // 请求如果用时太长，期间 cancel 了，马上就抛出异常退出了
  func cancel_network() async {
    let task = Task {
      print("begin")
      let url = URL(string: "https://mock.httpstatus.io/200?delay=10000")!
      let (data, _) = try await URLSession.shared.data(from: url)
      print("end")
      return data
    }
    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
      print("cancel")
      task.cancel()
    }
    do {
      let data = try await task.value
      print(data)
      print("final")
    } catch {
      print("task was cancelled")
    }
  }
}
