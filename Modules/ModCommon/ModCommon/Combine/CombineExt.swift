//
//  CombExt.swift
//  ModCommon
//
//  Created by Kevin Wu on 2022/1/1.
//

import UIKit
import Combine

public extension Subscribers.Completion {
  var isFinished: Bool {
    if case .finished = self {
      return true
    }
    return false
  }
  var isFailure: Bool {
    if case .failure = self {
      return true
    }
    return false
  }
}


public extension Publisher where Failure == Never {
  func mapToEvent(_ h: @escaping (Output)->Bool) -> AnyPublisher<Void,Never> { // CLOS
    filter(h)
      .map { _ in () }
      .eraseToAnyPublisher()
  }
}

public extension Publisher {
  func fallth(_ h: @escaping (Output)->Void) -> AnyPublisher<Output,Failure> { // CLOS
    map {
      h($0)
      return $0
    }
    .eraseToAnyPublisher()
  }
}

public extension Collection where Element: Publisher {
  func merge() -> Publishers.MergeMany<Element> {
    Publishers.MergeMany(self)
  }
}
