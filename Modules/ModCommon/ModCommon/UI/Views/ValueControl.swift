//
//  ValueControl.swift
//  ModCommon
//
//  Created by Kevin Wu on 2022/1/1.
//

import UIKit

/*
 override func setup() {
   super.setup()
   guard initialized else { return }

   reload(nil, false)
 }

 @objc func buttonAction(_ sender: UIButton) {
   reset(sender.tag, true, true)
 }

 var current = 0
 var didChange: ((Int)->Void)?
 func reload(_ old: Int?, _ animated: Bool) {
   // ...
 }
*/

public protocol ValueControl: AnyObject {
  associatedtype Value: Equatable
  var current: Value { get set } // internal use only
  var didChange: ((Value)->Void)? { get set }

  func notify()
  func reset(_ value: Value, _ animated: Bool, _ notify: Bool)
  func reload(_ old: Value?, _ animated: Bool) // internal use only
}

public extension ValueControl {
  func notify() {
    didChange?(current)
  }
  func reset(_ value: Value, _ animated: Bool, _ notify: Bool) {
    let oldValue = current
    current = value
    reload(oldValue, animated)
    if notify {
      didChange?(value)
    }
  }
}
