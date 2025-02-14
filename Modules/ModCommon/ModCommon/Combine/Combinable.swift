//
//  Combinable.swift
//  ModCommon
//
//  Created by Kevin Wu on 2022/1/1.
//

import UIKit
import Combine

public protocol Combinable: AnyObject {
  var cancellables: Set<AnyCancellable> { get set }
}


open class BaseObject: Combinable {
  public init() { }
  public lazy var cancellables = Set<AnyCancellable>()
}

open class BaseCocoa: NSObject, Combinable {
  public lazy var cancellables = Set<AnyCancellable>()
}
