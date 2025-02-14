//
//  ControlProperty.swift
//  ModCommon
//
//  Created by Kevin Wu on 2022/1/1.
//

import UIKit
import Combine

public extension Comb where Base: UITextField {

  var text: AnyPublisher<String?,Never> {
    Publishers
      .ControlProperty(control: base, event: [.editingChanged, .editingDidEnd, .editingDidEndOnExit], keyPath: \.text)
      .eraseToAnyPublisher()
  }

}

public extension Publishers {

  struct ControlProperty<Control: UIControl, Value>: Publisher {
    public typealias Output = Value
    public typealias Failure = Never

    let control: Control
    let event: Control.Event
    let keyPath: KeyPath<Control,Value>

    public func receive<S: Subscriber>(subscriber: S) where S.Failure == Failure, S.Input == Output {
      let subscription = Subscription(subscriber, control, event, keyPath)
      subscriber.receive(subscription: subscription)
    }

    class Subscription<S: Subscriber, C: UIControl, V>: Combine.Subscription where S.Input == V {
      let subscriber: S
      let control: C
      let event: C.Event
      let keyPath: KeyPath<C,V>

      init(_ subscriber: S,
           _ control: C,
           _ event: C.Event,
           _ keyPath: KeyPath<C,V>
      ) {
        self.subscriber = subscriber
        self.control = control
        self.event = event
        self.keyPath = keyPath
        setup()
      }
      func setup() {
        control.addTarget(self, action: #selector(handle), for: event)
      }

      var initialEmitted = false

      func request(_ demand: Subscribers.Demand) {
        // Emit initial value upon first demand request
        if demand > .none {
          if !initialEmitted {
            initialEmitted = true
            _ = subscriber.receive(control[keyPath: keyPath])
          }
        }
      }

      func cancel() {
        control.removeTarget(self, action: #selector(handle), for: event)
      }

      @objc func handle() {
        _ = subscriber.receive(control[keyPath: keyPath])
      }
    }
  }

}
