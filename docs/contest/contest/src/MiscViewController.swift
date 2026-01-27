//
//  MiscViewController.swift
//  contest
//
//  Created by Kevin Wu on 1/25/26.
//

import UIKit

// ================================================================================
// await 等待结束的时候，线程可能和 await 之前不一样，程序员不应该在线程这方面做出任何假设
//
// await 是潜在的切换线程点，等待结束的时候，回来的点可能在任意线程
//   我想了想：如果此函数没有标注为 MainActor，回来的时候可能会在任意线程，但如果标注了，肯定在主线程
// 如果回来的时候更新界面，会有异常，但是教程说，在任意线程给 @State 赋值，从而更新界面，不会有问题，因为 @State 有特殊处理
// 有空验证一下


// ================================================================================
// CheckedContinuation<String, Never> 返回 String 且不出错的 CheckedContinuation
// UnsafeContinuation<[Int], Error>   返回 [Int]  且会出错的 UnsafeContinuation
//
// 有些功能的回调是通过 delegate，且两个函数，这时可以把 continuation 存下来，然后在那两个函数里面分别调用
// try await withCheckedThrowingContinuation { continuation in
//     locationContinuation = continuation
//     manager.requestLocation()
// }
// locationContinuation?.resume(throwing: error)
// locationContinuation?.resume(returning: locations.first?.coordinate)


// ================================================================================
// Donny Wals 的一个示例，写的不错
// func refreshToken() async throws -> Token {
//   if let refreshTask = refreshTask {
//     // 大家等在这里，确保只有一个刷新任务在执行
//     return try await refreshTask.value
//   }
//   let task = Task { () throws -> Token in
//     // 看看如何置空已完成任务的
//     // 试了，这样置空真的行
//     defer { refreshTask = nil }
//
//     let tokenExpiresAt = Date().addingTimeInterval(10)
//     let newToken = Token(validUntil: tokenExpiresAt, id: UUID())
//     currentToken = newToken
//
//     return newToken
//   }
//   self.refreshTask = task
//   return try await task.value
// }


// ================================================================================
// https://www.donnywals.com/preconcurrency-usage-in-swift-explained/
// @preconcurrency
// 1) 掩盖三方库内部 Concurrency 相关的警告信息，我们改不了这些三方库，这能让它们闭嘴
// 2) 两处旧代码，我把某一处升级成并发了，为了让另一处旧代码还能继续用，而不至于到处都是警告错误，在新代码那边加上
//    它用在类型声明前的时候，作用相当剔除掉了后面的声明，比如 @preconcurrency @MainActor，相当于告诉编译器：没有这个 @MainActor
//
// 针对情况 2，当前 Build Settings 默认 actor 是 nonisolated
// 这是新代码，它实现了并发，它必须处于 MainActor
@preconcurrency
@MainActor
public final class CatalogViewModel {
  public private(set) var books: [String] = []
  public init() {}
  public func loadBooks() {}
}
// 这是旧代码，它现在不在 MainActor
// @MainActor
class TestClass {
  func run() {
    let obj = CatalogViewModel()
    obj.loadBooks()
  }
}
// 为了让旧代码能用上新代码的功能，1)在旧代码前添加 @MainActor；2)在新代码前加 @preconcurrency
//
// 5,minimal , 有 @preconcurrency 就成功，无就报错
// 5,targeted, 有 @preconcurrency 就成功，无就报错
// 5,complete, 有 @preconcurrency 就报警告，无就报错
// 6,minimal , 有 @preconcurrency 就报警告，无就报错
// 6,targeted, 有 @preconcurrency 就报警告，无就报错
// 6,complete, 有 @preconcurrency 就报警告，无就报错


class MiscViewController: UIViewController {

  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesEnded(touches, with: event)
    Task {
    }
  }

  // ================================================================================
  // 教程说 DispatchQueue.main.async 也是在 runloop 后执行，但文档没说，验证一下
  // 看运行后的结果，的确有那效果
  func async_order_1() {
    print("111")
    //DispatchQueue.main.async { print("doit1") }
    item = DispatchWorkItem { print("doit1") }
    DispatchQueue.main.async(execute: item!)
    print("aa")
    item = DispatchWorkItem { print("doit1") }
    DispatchQueue.main.async(execute: item!)
    print("bb")
    item = DispatchWorkItem { print("doit1") }
    DispatchQueue.main.async(execute: item!)
    print("cc")
    item = DispatchWorkItem { print("doit1") }
    DispatchQueue.main.async(execute: item!)
    print("222")
  }
  var item: DispatchWorkItem? {
    didSet {
      oldValue?.cancel()
    }
  }

  // ================================================================================
  func test1() {
    // 就算在异步环境中，调用 async 函数也必须添加 await，否则编译错误
    Task {
      let str = await doit1()
      print(str)
      // doit1()
    }
  }
  func doit1() async -> String {
    print("doit1")
    return "asdf"
  }

  // ================================================================================
  // 异步的 getter，只能只读，加 setter 会出错
  // 其实也就相当于计算属性，下面是 Task.value 的声明
  // var value: Success { get async throws }
  var prop1: Int {
    get async /* throws */ {
      10
    }
    // set { }
  }

  // ================================================================================
  // completion 和 async 方法能同名
  func func_name() async {
    let list1 = await fetchLatestNews()
    print(list1)
    fetchLatestNews { list2 in
      print(list2)
    }
  }
  // _ completion 也行
  func fetchLatestNews(completion: @escaping ([String]) -> Void) {
    DispatchQueue.main.async {
      completion(["11", "22"])
    }
  }
  func fetchLatestNews() async -> [String] {
    return ["aa", "bb"]
  }

}
