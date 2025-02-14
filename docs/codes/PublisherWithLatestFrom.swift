//
//  WithLatestFrom.swift
//  AppCommon
//
//  Created by Kevin Wu on 2022/1/1.
//

import UIKit
import Combine

public extension Publisher {

  func withLatestFrom<Other1: Publisher, Result>(_ other1: Other1,
                                                 _ resultSelector: @escaping (Output, Other1.Output) -> Result
  ) -> Publishers.WithLatestFrom<Self, Other1, Result> {
    .init(upstream: self,
          other: other1,
          resultSelector: resultSelector)
  }

  func withLatestFrom<Other1: Publisher, Other2: Publisher, Result>(_ other1: Other1,
                                                                    _ other2: Other2,
                                                                    _ resultSelector: @escaping (Output, (Other1.Output, Other2.Output)) -> Result
  ) -> Publishers.WithLatestFrom<Self, AnyPublisher<(Other1.Output, Other2.Output), Self.Failure>, Result> where Other1.Failure == Failure, Other2.Failure == Failure {
    .init(upstream: self,
          other: other1.combineLatest(other2).eraseToAnyPublisher(),
          resultSelector: resultSelector)
  }

  func withLatestFrom<Other1: Publisher, Other2: Publisher, Other3: Publisher, Result>(_ other1: Other1,
                                                                                       _ other2: Other2,
                                                                                       _ other3: Other3,
                                                                                       _ resultSelector: @escaping (Output, (Other1.Output, Other2.Output, Other3.Output)) -> Result
  ) -> Publishers.WithLatestFrom<Self, AnyPublisher<(Other1.Output, Other2.Output, Other3.Output), Self.Failure>, Result> where Other1.Failure == Failure, Other2.Failure == Failure, Other3.Failure == Failure {
    .init(upstream: self,
          other: other1.combineLatest(other2, other3).eraseToAnyPublisher(),
          resultSelector: resultSelector)
  }


  func withLatestFrom<Other1: Publisher>(_ other1: Other1
  ) -> Publishers.WithLatestFrom<Self, Other1, Other1.Output> {
    withLatestFrom(other1) { $1 }
  }

  func withLatestFrom<Other1: Publisher, Other2: Publisher>(_ other1: Other1,
                                                            _ other2: Other2
  ) -> Publishers.WithLatestFrom<Self, AnyPublisher<(Other1.Output, Other2.Output), Self.Failure>, (Other1.Output, Other2.Output)> where Other1.Failure == Failure, Other2.Failure == Failure {
    withLatestFrom(other1, other2) { $1 }
  }

  func withLatestFrom<Other1: Publisher, Other2: Publisher, Other3: Publisher>(_ other1: Other1,
                                                                               _ other2: Other2,
                                                                               _ other3: Other3
  ) -> Publishers.WithLatestFrom<Self, AnyPublisher<(Other1.Output, Other2.Output, Other3.Output), Self.Failure>, (Other1.Output, Other2.Output, Other3.Output)> where Other1.Failure == Failure, Other2.Failure == Failure, Other3.Failure == Failure {
    withLatestFrom(other1, other2, other3) { $1 }
  }

}

public extension Publishers {

  struct WithLatestFrom<Upstream: Publisher, Other: Publisher, Output>: Publisher where Upstream.Failure == Other.Failure {
    public typealias Failure = Upstream.Failure
    public typealias ResultSelector = (Upstream.Output, Other.Output) -> Output

    let upstream: Upstream
    let other: Other
    let resultSelector: ResultSelector

    public func receive<S: Subscriber>(subscriber: S) where Failure == S.Failure, Output == S.Input {
      let subscription = Subscription(subscriber, upstream, other, resultSelector)
      subscriber.receive(subscription: subscription)
    }
  }

}

extension Publishers.WithLatestFrom {

  class Subscription<S: Subscriber>: Combine.Subscription where S.Input == Output, S.Failure == Failure {
    let subscriber: S
    let upstream: Upstream
    let other: Other
    let resultSelector: ResultSelector

    var otherLatestValue: Other.Output?

    var upstreamSubscription: Cancellable?
    var otherSubscription: Cancellable?

    init(_ subscriber: S,
         _ upstream: Upstream,
         _ other: Other,
         _ resultSelector: @escaping ResultSelector
    ) {
      self.subscriber = subscriber
      self.upstream = upstream
      self.other = other
      self.resultSelector = resultSelector
      setup()
    }
    // Create an internal subscription to the `Other` publisher,
    // constantly tracking its latest value
    func setup() {
      let subscriber = AnySubscriber<Other.Output, Other.Failure>(
        receiveSubscription: { [weak self] in
          self?.otherSubscription = $0
          $0.request(.unlimited)
        },
        receiveValue: { [weak self] in
          self?.otherLatestValue = $0
          return .unlimited
        },
        receiveCompletion: nil
      )
      other.subscribe(subscriber)
    }

    func request(_ demand: Subscribers.Demand) {
      // withLatestFrom always takes one latest value from the other
      // observable, so demand doesn't really have a meaning here.
      upstreamSubscription = upstream
        .sink(
          receiveCompletion: { [weak self] in
            self?.subscriber.receive(completion: $0)
          },
          receiveValue: { [weak self] in
            guard let self = self else { return }
            guard let value = self.otherLatestValue else { return }
            _ = self.subscriber.receive(self.resultSelector($0, value))
          }
        )
    }

    func cancel() {
      upstreamSubscription?.cancel()
      otherSubscription?.cancel()
    }
  }

}
