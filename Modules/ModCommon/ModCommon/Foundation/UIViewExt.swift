//
//  UIViewExt.swift
//  ModCommon
//
//  Created by Kevin Wu on 2022/1/1.
//

import UIKit

// autocapitalizationType = .none
// autocorrectionType = .no
// spellCheckingType = .no

// shadowColor
// shadowRadius   3.0           半径，值越大阴影延伸的越远越淡
// shadowOpacity  0.0           不透明度，最大值 1
// shadowOffset   (0.0, -3.0)   偏移量，负值往左上偏移

// cancelsTouchesInView = true  手势识别成功后是否取消视图的触摸事件，通过发送 touch cancelled
// delaysTouchesBegan = false   手势识别成功后视图收不到触摸事件，失败后才会发 touch began 给视图
// delaysTouchesEnded = true    手势识别成功后视图收到 touch cancelled，失败后才会发 touch ended 给视图

public extension UIView {
  var isShown: Bool {
    get { !isHidden }
    set { isHidden = !newValue }
  }

  var imageRep: UIImage {
    UIGraphicsImageRenderer(bounds: bounds).image {
      layer.render(in: $0.cgContext)
    }
  }

  // for cell
  static var reuseId: String {
    String(describing: self)
  }

  var responder: UIResponder? {
    if isFirstResponder {
      return self
    }
    for view in subviews {
      if let responder = view.responder {
        return responder
      }
    }
    return nil
  }


  func kangLa(_ priority: UILayoutPriority, _ axis: NSLayoutConstraint.Axis?) {
    if let axis = axis {
      setContentHuggingPriority(priority, for: axis)
    } else {
      setContentHuggingPriority(priority, for: .vertical)
      setContentHuggingPriority(priority, for: .horizontal)
    }
  }
  func kangYa(_ priority: UILayoutPriority, _ axis: NSLayoutConstraint.Axis?) {
    if let axis = axis {
      setContentCompressionResistancePriority(priority, for: axis)
    } else {
      setContentCompressionResistancePriority(priority, for: .vertical)
      setContentCompressionResistancePriority(priority, for: .horizontal)
    }
  }
  func degradeLaya(_ val: Int, _ axis: NSLayoutConstraint.Axis?) {
    if let axis = axis {
      setContentHuggingPriority(.defaultLow-Float(val), for: axis)
      setContentCompressionResistancePriority(.defaultHigh-Float(val), for: axis)
    } else {
      setContentHuggingPriority(.defaultLow-Float(val), for: .horizontal)
      setContentHuggingPriority(.defaultLow-Float(val), for: .vertical)
      setContentCompressionResistancePriority(.defaultHigh-Float(val), for: .horizontal)
      setContentCompressionResistancePriority(.defaultHigh-Float(val), for: .vertical)
    }
  }


  func addSubviews(_ views: [UIView]) {
    views.forEach { addSubview($0) }
  }
  func removeAllSubviews() {
    subviews.forEach { $0.removeFromSuperview() }
  }
  func bringToFront() {
    superview?.bringSubviewToFront(self)
  }
  func sendToBack() {
    superview?.sendSubviewToBack(self)
  }

  func descendant<T: UIView>(_ cls: T.Type) -> T? {
    if self is T {
      return self as? T
    }
    for it in subviews {
      if let v = it.descendant(cls) {
        return v
      }
    }
    return nil
  }
  func ancestor<T: UIView>(_ cls: T.Type) -> T? {
    if self is T {
      return self as? T
    } else {
      return superview?.ancestor(cls)
    }
  }


  // view.addPushTransition(.fromLeft) { print("push done") }
  // view.backgroundColor = .red
  //
  // navigationController?.view.addPushTransition(.fromRight) { print("pop done") }
  // navigationController?.popViewController(animated: false)
  func addPushTransition(_ subtype: CATransitionSubtype, _ completion: VoidCb?) {
    CATransaction.begin()
    let transition = CATransition()
    transition.duration = 0.35
    transition.type = .push
    transition.subtype = subtype
    transition.isRemovedOnCompletion = false
    transition.fillMode = .forwards
    CATransaction.setCompletionBlock(completion)
    layer.add(transition, forKey: "transition")
    CATransaction.commit()
  }


  // To use in code
  //   set View - Custom Class
  //   in code: XXXView.fromNib()
  static func fromNib() -> Self {
    UINib(nibName: String(describing: self), bundle: Bundle(for: self))
      .instantiate(withOwner: nil, options: nil).first as? Self ?? .init()
  }
  // To use in another xib
  //   set File's Owner - Custom Class
  //   in another xib, add a sub UIView, set its Custom Class
  //   in code: awakeFromNib() { ... }
  func loadContentFromNib() {
    UINib(nibName: String(describing: Self.self), bundle: Bundle(for: Self.self))
      .instantiate(withOwner: self, options: nil)
      .compactMap { $0 as? UIView }
      .forEach {
        $0.translatesAutoresizingMaskIntoConstraints = false
        addSubview($0)
        topAnchor.constraint(equalTo: $0.topAnchor).isActive = true
        bottomAnchor.constraint(equalTo: $0.bottomAnchor).isActive = true
        leadingAnchor.constraint(equalTo: $0.leadingAnchor).isActive = true
        trailingAnchor.constraint(equalTo: $0.trailingAnchor).isActive = true
      }
  }
}

public extension NSLayoutConstraint.Axis {
  var next: Self {
    self == .vertical ? .horizontal : .vertical
  }
  var isVertical: Bool {
    self == .vertical
  }
  var isHorizontal: Bool {
    self == .horizontal
  }
}


public extension UIStackView {
  func addArrangedSubviews(_ views: [UIView]) {
    views.forEach { addArrangedSubview($0) }
  }
  func removeAllArrangedSubviews() {
    arrangedSubviews.forEach { $0.removeFromSuperview() }
  }
}


public extension UIViewController {
  func addSubvc(_ child: UIViewController, _ inView: UIView?) {
    addChild(child)
    (inView ?? view).addSubview(child.view)
    child.didMove(toParent: self)
  }
  func removeSubvc(_ child: UIViewController) {
    child.willMove(toParent: nil)
    child.view.removeFromSuperview()
    child.removeFromParent()
  }
}


public extension UIView {
  var owner: UIViewController? {
    var responder: UIResponder? = self
    while !(responder is UIViewController) {
      responder = responder?.next
      if responder == nil { break }
    }
    return (responder as? UIViewController)
  }
}
public extension UIViewController {
  var ancestor: UIViewController? {
    var ret = self
    while let vc = ret.parent {
      ret = vc
    }
    return ret
  }
}
public extension UINavigationController {
  var root: UIViewController? { viewControllers.at(0) }
  var top: UIViewController? { topViewController }
}


// ValueControl
//
// private(set) var current = 0
// var didChange: ((Int)->Void)?
//
// func reset(_ value: Int, _ animated: Bool, _ notify: Bool) {
//   let oldValue = current
//   current = value
//   reload(oldValue, animated)
//   if notify {
//     didChange?(value)
//   }
// }
// func reload(_ old: Int?, _ animated: Bool) {
//   stackView.arrangedSubviews
//     .compactMap { $0 as? UIButton }
//     .forEach { $0.setTitleColor($0.tag == current ? .red : .blue, for: .normal) }
// }
//
// // init
// reload(nil, false)
//
// // fire
// reset(sender.tag, true, true)
