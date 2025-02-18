//
//  Comb.swift
//  ModCommon
//
//  Created by Kevin Wu on 2022/1/1.
//

import UIKit
import Combine

public class Comb<Base> {
  let base: Base
  init(_ base: Base) {
    self.base = base
  }
}

public protocol Combe {
  associatedtype CombBase
  var cmb: Comb<CombBase> { get }
}

public extension Combe {
  var cmb: Comb<Self> { Comb(self) }
}

extension NSObject: Combe { }


// =============================================================================

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
