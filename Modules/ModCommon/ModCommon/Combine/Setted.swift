//
//  Setted.swift
//  ModCommon
//
//  Created by Kevin Wu on 2022/1/1.
//

import UIKit
import Combine

// $age.refresher.config(60*60*24) { [weak self] h in
//   guard let self = self else { return }
//   masy(2) { [weak self] in
//     guard let self = self else { return }
//     //h(.success(self.age + 1))
//     //h(.failure(HttpError.cancelled))
//   }
// }
//
// $age.refresher.run(nil)
// $age.refresher.runIfNeeded(nil)

@propertyWrapper
public struct Setted<Output>: Publisher {
  public typealias Failure = Never

  let subject: CurrentValueSubject<Output, Never>

  public init(wrappedValue: Output) {
    subject = CurrentValueSubject<Output, Never>(wrappedValue)
    refresher = Refresher(subject)
  }

  public var wrappedValue: Output {
    get { subject.value }
    nonmutating set { subject.send(newValue) }
  }

  public var projectedValue: Setted<Output> { self }

  public func receive<S: Subscriber>(subscriber: S) where S.Failure == Failure, S.Input == Output {
    subject.receive(subscriber: subscriber)
    refresher.runIfNeeded(nil)
  }


  public class Refresher {
    let subject: CurrentValueSubject<Output, Never>
    init(_ sub: CurrentValueSubject<Output, Never>) {
      subject = sub
    }

    public var timeouter = Timeouter(.day(365))
    public typealias Completion = (Result<Output,Error>) -> Void // CLOS
    public var work: ((@escaping Completion)->Void)? // CLOS
    public func config(_ interval: Timeint, _ work: ((@escaping Completion)->Void)?) { // CLOS
      timeouter.interval = interval
      self.work = work
    }

    public var running = false
    public func runIfNeeded(_ completion: Completion?) {
      if timeouter.expired {
        run(completion)
      } else {
        if running {
          if let completion = completion {
            completions.append(completion)
          }
        } else {
          completion?(.success(subject.value))
        }
      }
    }
    public func run(_ completion: Completion?) {
      if let completion = completion {
        completions.append(completion)
      }
      if !running {
        running = true
        work?({ [weak self] res in
          guard let self = self else { return }
          if case let .success(val) = res {
            self.subject.send(val)
            self.timeouter.renew()
          }
          self.running = false
          self.completions.forEach { $0(res) }
          self.completions.removeAll()
        })
      }
    }
    var completions: [Completion] = []
  }
  public let refresher: Refresher
}
