//
//  StreamViewController.swift
//  contest
//
//  Created by Kevin Wu on 1/25/26.
//

import UIKit

class StreamViewController: UIViewController {

  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesEnded(touches, with: event)
    Task {
      await async_stream_4()
    }
    //    async_stream_3()
  }

  // ================================================================================
  // AsyncStream 对应的是 continuation
  //   continuation 把 completion 转化为 async 函数
  //   AsyncStream 把 xxx 转化为异步序列
  // 和 PassthroughSubject 类似，手动往里面传值
  //
  // 当外面接收方取消了，可以这样结束数据
  // self.continuation?.onTermination = { result in
  //   print(result)
  //   self.continuation = nil
  // }
  // 读读这里关于 AsyncStream 的取消情况
  // https://www.donnywals.com/building-an-asyncsequence-with-asyncstream-makestream/
  //
  // 教程说：抛出异常之前的数据能正常被收到，之后再也不会有新数据，未验证
  func async_stream_1() async {
    let stream = AsyncStream { continuation in
      for i in 1...9 {
        continuation.yield(i)
      }
      continuation.finish()
    }
    for await item in stream {
      print(item)
    }
  }

  // ================================================================================
  // AsyncStream 有三种缓存策略
  // 如果缓存数量是 0，且当前没人在接收数据，马上就丢弃了
  // 试试几个的效果，有点小惊喜
  // 感觉还是少用 0 吧，因为用 0 的时候，不管是 最新/最旧，收到的都是第一个，解释不清楚
  // 教程说 0 缓存的使用场景是：比如我要观察目录变化，只接收我订阅之后的变化，之前的全部不要
  func async_stream_2() async {
    let stream = AsyncStream(bufferingPolicy: .bufferingOldest(0)) { continuation in
      print("begin")
      // 1) 同步产生数据
      // 如果用 .bufferingOldest(0) / .bufferingNewest(0)，数据全部丢失了
      // continuation.yield("111")
      // continuation.yield("222")
      // continuation.yield("333")
      // continuation.yield("444")
      // continuation.finish()
      // 2) 异步产生数据
      Task {
        print("aaa")
        // try await Task.sleep(for: .seconds(2))
        continuation.yield("111")
        continuation.yield("222")
        continuation.yield("333")
        continuation.yield("444")
        continuation.finish() // 如果不要这句，接收方的 for await 会一直等下去
        print("bbb")
      }
      print("end")
    }
    print("subscribe")
    for await item in stream {
      print(item)
    }
    print("back")
  }

  // ================================================================================
  // 三个任务共同消化 stream 的元素，并不是每个任务内部循环 9 次
  // 如果要每个任务都收到 0-9，得用 Combine.Publisher
  // 1. 1
  // 2. 2
  // 3. 3
  // 1. 4
  // 2. 5
  // 3. 6
  // 1. 7
  // 3. 8   <= 顺序还不一样
  // 2. 9
  func async_stream_3() {
    let stream = AsyncStream { continuation in
      for i in 1...9 {
        continuation.yield(i)
      }
      continuation.finish()
    }
    Task {
      for await item in stream {
        print("1. \(item)")
      }
    }
    Task {
      for await item in stream {
        print("2. \(item)")
      }
    }
    Task {
      for await item in stream {
        print("3. \(item)")
      }
    }
  }

  // ================================================================================
  func async_stream_4() async {
    let stream = AsyncStream { continuation in
      for i in 1...9 {
        continuation.yield(i)
      }
      continuation.finish()
    }
    // 先取出来，然后在 for 里面遍历 firstThree 效果也是一样的
    // let firstThree = stream.prefix(3)
    for _ in 1...3 {
      print("The next three are:")
      // stream.prefix(3) 取 stream 当前状态的前三个
      for await item in stream.prefix(3) {
        print(item)
      }
    }
  }

}
