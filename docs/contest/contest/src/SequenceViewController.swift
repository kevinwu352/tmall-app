//
//  SequenceViewController.swift
//  contest
//
//  Created by Kevin Wu on 1/25/26.
//

import UIKit

// Sequence 对应 AsyncSequence
// 异步的关注两点：
//   数据接收方 等待数据
//   数据接收方 响应不及时，数据来的太快，接收方太慢，这时要 丢弃一些 / 缓存一点


// 将异步序列转化为正常序列
// 这是教程上给的例子，这里有一个编译错误，以后来处理
// extension AsyncSequence {
//   func collect() async throws -> [Element] {
//     try await reduce(into: [Element]()) { $0.append($1) }
//   }
// }


class SequenceViewController: UIViewController {

  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesEnded(touches, with: event)
    Task {
//      try? await access_async_sequence()
      await custom_sequence()
    }
//    erase_sequence_type()
  }

  // ================================================================================
  // 没有 Combine.Publisher.eraseToAnyPublisher() 之类的东西
  // 可以直接赋值，但 seq 的类型最好声明为 any AsyncSequence，否则有警告
  var sequence: (any AsyncSequence)?
  // var sequence: AsyncSequence?
  func erase_sequence_type() {
    let url = URL(string: "https://hws.dev/users.csv")!
    let ret = url.lines
      .map {  Int($0) }
      .prefix(10)
    sequence = ret
  }

  // ================================================================================
  func access_async_sequence() async throws {
    let url = URL(string: "https://hws.dev/users.csv")!

    // 方法一：遍历
    // for try await line in url.lines {
    //   print("Received user: \(line)")
    // }

    // 方法二：调用 next()
    var iterator = url.lines.makeAsyncIterator()
    if let line = try await iterator.next() {
      print("first: \(line)")
    }
    if let line = try await iterator.next() {
      print("second: \(line)")
    }
  }

  // ================================================================================
  func custom_sequence() async {
    let seq = DoubleGenerator2()
    for await number in seq {
      print(number)
    }
  }

}

// 自定义 AsyncSequence 方式一
struct DoubleGenerator1: AsyncSequence, AsyncIteratorProtocol {
  var current = 1
  mutating func next() async -> Int? {
    // 安全地乘以 2，溢出后变成负数，否则会运行时异常
    defer { current &*= 2 }
    return current < 0 ? nil : current
  }
  func makeAsyncIterator() -> DoubleGenerator1 {
    self
  }
}
// 自定义 AsyncSequence 方式二
struct DoubleGenerator2: AsyncSequence {
  // typealias Element = Int
  struct AsyncIterator: AsyncIteratorProtocol {
    var current = 9
    mutating func next() async -> Int? {
      defer { current -= 2 }
      // 减慢生产数据的速度
      try? await Task.sleep(for: .seconds(1))
      return current <= 0 ? nil : current
    }
  }
  func makeAsyncIterator() -> AsyncIterator {
    AsyncIterator()
  }
}
