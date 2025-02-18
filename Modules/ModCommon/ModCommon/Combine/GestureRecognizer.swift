//
//  GestureRecognizer.swift
//  ModCommon
//
//  Created by Kevin Wu on 2022/1/1.
//

import UIKit
import Combine

public extension Comb where Base: UIGestureRecognizer {
  var publisher: AnyPublisher<UIGestureRecognizer,Never> {
    Publishers
      .GestureRecognizer(recognizer: base)
      .eraseToAnyPublisher()
  }
}

public extension Publishers {

  struct GestureRecognizer<Recognizer: UIGestureRecognizer>: Publisher {
    public typealias Output = Recognizer
    public typealias Failure = Never

    let recognizer: Recognizer

    public func receive<S: Subscriber>(subscriber: S) where S.Failure == Failure, S.Input == Output {
      let subscription = Subscription(subscriber, recognizer)
      subscriber.receive(subscription: subscription)
    }

    class Subscription<S: Subscriber, R: UIGestureRecognizer>: Combine.Subscription where S.Input == R {
      let subscriber: S
      let recognizer: R

      init(_ subscriber: S,
           _ recognizer: R
      ) {
        self.subscriber = subscriber
        self.recognizer = recognizer
        setup()
      }
      func setup() {
        recognizer.addTarget(self, action: #selector(handle))
      }

      func request(_ demand: Subscribers.Demand) {
      }

      func cancel() {
        recognizer.removeTarget(self, action: #selector(handle))
      }

      @objc func handle(_ sender: UIGestureRecognizer) {
        _ = subscriber.receive(recognizer)
      }
    }
  }

}
