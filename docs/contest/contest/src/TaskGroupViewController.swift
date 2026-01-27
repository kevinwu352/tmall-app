//
//  TaskGroupViewController.swift
//  contest
//
//  Created by Kevin Wu on 1/26/26.
//

import UIKit

// 结构化并发，async let / TaskGroup，父任务等子任务执行完成
// 非结构化并发，Task.init，继承当前环境的一些属性（actor/Task Local Values/priority），它不是子任务，当前函数结束后，它还能运行
// 非结构化并发，Task.detached，不继承，完全脱离，放飞自我，大佬们建议不要用
// 非结构化并发，Task.immediate


// group 适合不定数量，而 async let/Task 无法，固定它们的数量是写死在代码里的
// task 和 group 能显式 cancel，async let 不行，它们仨都能取消，但这里说的是显式取消，也就是说有 cancel 方法可供程序员调用
// task 创建后能存起来，async let 不行
// group 返回类型要相同，能用 enum 规避
// group 返回值的顺序是随机的，而 async let/Task 不同，你创建这些任务后，你得 await 它们，这个 await 的顺序就是等的顺序，这是写死在代码里的
//
// 虽然 async let 看起来一无是处，但推荐使用的顺序是：async let / task / task-group


class TaskGroupViewController: UIViewController {

  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesEnded(touches, with: event)
    Task {
      await discard_group()
    }
  }

  // ================================================================================
  // 正常版本 / Throwing 版本的
  // 正常版本 / Discarding 版本
  // 总共 4 种创建 TaskGroup 的方式
  // withTaskGroup(of: Sendable.Type, returning: GroupResult.Type, body: (inout TaskGroup<Sendable>) async -> GroupResult)
  // withDiscardingTaskGroup(returning: GroupResult.Type, body: (inout DiscardingTaskGroup) async -> GroupResult)
  // 参数 of 是子任务的返回值
  // 参数 returning 是整个 TaskGroup 的返回值
  //
  // TaskGroup 是 AsyncSequence，所以，可以用 for await / group.next() 来获取子任务返回的数据
  //
  // 文档里说，group 的生命周期不应该比 with***Group 函数长，不应该把 group 保存到其它地方
  func simple_test() async {
    let string = await withTaskGroup { group in
      // group.addTask 参数里那个闭包是 async 的，但是 addTask 这个方法本身不是
      // 所以无法 await group.addTask
      group.addTask { "Hello" }
      group.addTask { "From" }
      group.addTask { "A" }
      group.addTask { "Task" }
      group.addTask { "Group" }
      var collected = [String]()
      // 这里收到的顺序并非上面添加任务的顺序
      for await value in group {
        collected.append("\(value)")
      }
      return collected.joined(separator: " ")
    }
    print(string)
  }

  // ================================================================================
  // 文档说：就算只等第一个任务的结果，TaskGroup 也会等所有的子任务结束，这就是结构化并发
  // 的确如此，虽然只取第一个任务的返回值，但是依然会等所有任务结束，然后 withTaskGroup 才会结束
  //
  // 所以，我们最好明确地等我们所添加的所有任务，不要漏了某一个，让人产生疑惑
  // 虽然你不等，TaskGroup 自己也会等所有的结束，但最好不要这样子
  func wait_all() async {
    print("begin")
    let value = await withTaskGroup { group in
      group.addTask {
        print("11a")
        try? await Task.sleep(for: .seconds(10))
        print("11b")
        return 101
      }
      group.addTask {
        print("22a")
        try? await Task.sleep(for: .seconds(2))
        print("22b")
        return 102
      }

      // 虽然我只取第一个任务的返回值，但 TaskGroup 会等所有的任务完成
      // waitForAll 这句其实没什么必要，但是，如果加上的话，它会把所有的值都吃完
      // 导致 group.next() 没有值了，它相当于已经把这个 Sequence 给遍历完了
      // await group.waitForAll()
      return await group.next()

      // 就算我什么都不等，也不使用两个任务的返回值，而是直接返回一个固定值，TaskGroup 也会等两个任务完成，再完成
      // return "done"
    }
    print(value)
    print("end")
  }

  // ================================================================================
  // withDiscardingTaskGroup 是一种自动丢弃 task 的 group，不会导致内存持续增长
  // 下例中，如果使用 withTaskGroup，内存会每秒涨 0.5M，且持续增长
  // 这种 TaskGroup 的使用场景是长期运行的服务，比如 HTTP 服务器，接收新连接，创建 task 去处理，回复以后丢弃 task
  func discard_group() async {
    let generator = RandomGenerator()
    // await withTaskGroup { group in
    await withDiscardingTaskGroup { group in
      for await newNumber in generator {
        group.addTask {
          print(newNumber)
        }
      }
    }
  }

}

struct RandomGenerator: AsyncSequence, AsyncIteratorProtocol {
  mutating func next() async -> Int? {
    try? await Task.sleep(for: .seconds(0.001))
    return Int.random(in: 1...Int.max)
  }
  func makeAsyncIterator() -> Self {
    self
  }
}
