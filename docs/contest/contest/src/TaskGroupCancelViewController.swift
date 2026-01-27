//
//  TaskGroupCancelViewController.swift
//  contest
//
//  Created by Kevin Wu on 1/27/26.
//

import UIKit

// TaskGroup 三种情况会取消：
//   父任务取消了
//   自己上面调用 cancelAll()
//   某个子任务异常了

class TaskGroupCancelViewController: UIViewController {

  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesEnded(touches, with: event)
    Task {
      await throw_excep_2()
    }
  }

  // ================================================================================
  // 首先，调用 cancelAll() 并不会产生任何异常，所以，可以用无异常版本的 withTaskGroup
  //   接收数据时用的是 for await，而不是 for try await
  // 其次，虽然调用了取消，但子任务并未检查取消，所以三个任务还是会完成，且顺序随机
  // 再者，这里不是说取消的时候，三个任务可能已经开始执行，导致有些任务可能在取消前完成，不是这样
  //   从日志来看，取消是在先，三个任务是在后，只是这三任务没有响应取消而已
  func cancel_all_1() async {
    let result = await withTaskGroup { group in
      group.addTask {
        print("111")
        return "aaa"
      }
      group.addTask {
        print("222")
        return "bbb"
      }
      group.addTask {
        print("333")
        return "ccc"
      }

      print("cancel")
      group.cancelAll()

      var list: [String] = []
      for await value in group {
        list.append(value)
      }
      return list.joined(separator: ", ")
    }
    print(result)
  }

  // cancelAll 只取消还在的任务，已完成的影响不了，已经完成的已经通过 try await 写进数组里了
  //   又因为顺序是随机的，所以，在 bbb 检查取消的时候，aaa/ccc 可能都完成了，也可能都没完成，反正不一定
  // 所以打印的是：先抓住异常并打印，然后把已经拿到的数据返回，最后打印返回的数据
  //
  // 这里必须使用 Throwing 版本是因为 checkCancellation，而不是 for try await
  func cancel_all_2() async {
    let result = await withThrowingTaskGroup { group in
      group.addTask { "aaa" }
      group.addTask {
        try Task.checkCancellation()
        return "bbb"
      }
      group.addTask { "ccc" }

      group.cancelAll()

      var list: [String] = []
      do {
        for try await value in group {
          list.append(value)
        }
      } catch {
        print("got \(error)")
      }
      return list.joined(separator: ", ")
    }
    print(result)
  }

  // ================================================================================
  // 在不用 for await/group.next 的情况下，没读取子任务的值，子任务抛出的异常对 TaskGroup 无影响
  //   TaskGroup 会正常完成，catch 收不到里面子任务抛出的异常
  // 不管在 sleep 之 前/后 抛出异常，行为都是正常的，但要记住一点，TaskGroup 会等它所有的子任务
  // 特别注意：如果 5 先抛出异常，理论上 10 的 isCancelled 应该是 true，但事实并非如此，为什么呢？
  //   我的理解是，这里并没有解开子任务的值，也就是没有使用 for await/group.next，所以子任务的异常被掩盖了
  //   如果解开子任务的值，10 会被取消，且外面能收到异常
  // 所以，我们平时用的时候，自己添加的子任务，要去使用它的值，要去解开那个值，要不然你创建个子任务，然后丢弃，你搞毛啊？
  //   使用子任务值的时候，该抛的异常才会抛出来
  func throw_excep_1() async {
    do {
      let result = try await withThrowingTaskGroup { group in
        group.addTask {
          print("begin1")
          // throw Unicode.UTF8.ValidationError.Kind.truncatedScalar
          try await Task.sleep(for: .seconds(10))
          print("end1 \(Task.isCancelled)")
          // throw Unicode.UTF8.ValidationError.Kind.truncatedScalar
          return "aaa"
        }
        group.addTask {
          print("begin2")
          // throw Unicode.UTF8.ValidationError.Kind.truncatedScalar
          try await Task.sleep(for: .seconds(5))
          print("end2 \(Task.isCancelled)")
          throw Unicode.UTF8.ValidationError.Kind.truncatedScalar
          return "bbb"
        }

        // 这里是解开子任务的值
        // print(try await group.next())

        return "done"
      }
      print(result)
    } catch {
      print("got \(error)")
    }
  }

  // waitForAll() 会收到子任务抛出的异常，但它不等于解开子任务的值，因为其它子任务并未收到取消
  // 只是在所有任务完成后，它会把收到的异常抛出去，do-catch 能收到
  //
  // 从最终的效果上分析 waitForAll 的行为：
  // 它一定会等待所有的子任务完成，如果等待过程中收到异常，它会暂时装傻，不会因某个子任务异常而取消其它子任务
  // 直到所有子任务完成，再抛出异常
  // 如果多个子任务抛出异常，它抛出的是收到的第一个
  //
  // 所以，个人感觉，这玩意也少用，还是那句话，你创建了子任务就要用它的值，要不然你创建它干嘛？给自己找事？
  func throw_excep_2() async {
    do {
      let result = try await withThrowingTaskGroup { group in
        group.addTask {
          print("begin1")
          // throw Unicode.UTF8.ValidationError.Kind.truncatedScalar
          try await Task.sleep(for: .seconds(9))
          print("end1 \(Task.isCancelled)")
          // throw Unicode.UTF8.ValidationError.Kind.truncatedScalar
          return "aaa"
        }
        group.addTask {
          print("begin2")
          // throw Unicode.UTF8.ValidationError.Kind.truncatedScalar
          try await Task.sleep(for: .seconds(6))
          print("end2 \(Task.isCancelled)")
          // throw Unicode.UTF8.ValidationError.Kind.truncatedScalar
          return "bbb"
        }
        group.addTask {
          print("begin3")
          // throw Unicode.UTF8.ValidationError.Kind.truncatedScalar
          try await Task.sleep(for: .seconds(3))
          print("end3 \(Task.isCancelled)")
          // throw Unicode.UTF8.ValidationError.Kind.truncatedScalar
          return "ccc"
        }

        try await group.waitForAll()

        // 这行代码执行不到
        return "done"
      }
      print(result)
    } catch {
      print("got \(error)")
    }
  }

  // 总结：
  // 三个任务，会产生三个 值/异常，我用 group.next() 一个一个读取
  // 如果读取到异常，TaskGroup 就取消其它进行中的子任务，且 withThrowingTaskGroup 会抛出异常，do-catch 能收到
  //
  // 注意，如果 正常-异常-正常 这三个值，而我只 next 一次，相当于没解开第二个值，也就是没读取到异常，整个流程会正常结束
  // 最好不要这样子，还是那句话，自己创建的任务，一定要解开它们的值，让该抛的异常抛出来，否则你创建这子任务干嘛？
  //
  // 如果读取第四次，得到的是 nil
  func throw_excep_3() async {
    do {
      let result = try await withThrowingTaskGroup { group in
        group.addTask {
          print("begin1")
          // throw Unicode.UTF8.ValidationError.Kind.truncatedScalar
          try await Task.sleep(for: .seconds(9))
          print("end1 \(Task.isCancelled)")
          // throw Unicode.UTF8.ValidationError.Kind.truncatedScalar
          return "aaa"
        }
        group.addTask {
          print("begin2")
          // throw Unicode.UTF8.ValidationError.Kind.truncatedScalar
          try await Task.sleep(for: .seconds(6))
          print("end2 \(Task.isCancelled)")
          // throw Unicode.UTF8.ValidationError.Kind.truncatedScalar
          return "bbb"
        }
        group.addTask {
          print("begin3")
          // throw Unicode.UTF8.ValidationError.Kind.truncatedScalar
          try await Task.sleep(for: .seconds(3))
          print("end3 \(Task.isCancelled)")
          // throw Unicode.UTF8.ValidationError.Kind.truncatedScalar
          return "ccc"
        }

        let v1 = try await group.next()
        print(v1)
        let v2 = try await group.next()
        print(v2)
        let v3 = try await group.next()
        print(v3)
        let v4 = try await group.next()
        print(v4)

        return "done"
      }
      print(result)
    } catch {
      print("got \(error)")
    }
  }

}
