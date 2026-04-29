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

extension UIView {
  public var isShown: Bool {
    get { !isHidden }
    set { isHidden = !newValue }
  }

  public var imageRep: UIImage {
    UIGraphicsImageRenderer(bounds: bounds).image {
      layer.render(in: $0.cgContext)
    }
  }

  // for cell
  public static var reuseId: String {
    String(describing: self)
  }

  public var responder: UIResponder? {
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

  public func kangLa(_ priority: UILayoutPriority, axis: NSLayoutConstraint.Axis? = nil) {
    if let axis {
      setContentHuggingPriority(priority, for: axis)
    } else {
      setContentHuggingPriority(priority, for: .horizontal)
      setContentHuggingPriority(priority, for: .vertical)
    }
  }
  public func kangYa(_ priority: UILayoutPriority, axis: NSLayoutConstraint.Axis? = nil) {
    if let axis {
      setContentCompressionResistancePriority(priority, for: axis)
    } else {
      setContentCompressionResistancePriority(priority, for: .horizontal)
      setContentCompressionResistancePriority(priority, for: .vertical)
    }
  }
  public func degradeLaya(_ value: Int, axis: NSLayoutConstraint.Axis? = nil) {
    if let axis {
      setContentHuggingPriority(.defaultLow - Float(value), for: axis)
      setContentCompressionResistancePriority(.defaultHigh - Float(value), for: axis)
    } else {
      setContentHuggingPriority(.defaultLow - Float(value), for: .horizontal)
      setContentHuggingPriority(.defaultLow - Float(value), for: .vertical)
      setContentCompressionResistancePriority(.defaultHigh - Float(value), for: .horizontal)
      setContentCompressionResistancePriority(.defaultHigh - Float(value), for: .vertical)
    }
  }
  public func adaptLaya(_ value: Int, axis: NSLayoutConstraint.Axis? = nil) {
    if let axis = axis {
      setContentHuggingPriority(UILayoutPriority(Float(value)), for: axis)
      setContentCompressionResistancePriority(UILayoutPriority(Float(value)), for: axis)
    } else {
      setContentHuggingPriority(UILayoutPriority(Float(value)), for: .horizontal)
      setContentHuggingPriority(UILayoutPriority(Float(value)), for: .vertical)
      setContentCompressionResistancePriority(UILayoutPriority(Float(value)), for: .horizontal)
      setContentCompressionResistancePriority(UILayoutPriority(Float(value)), for: .vertical)
    }
  }

  public func addSubviews(_ views: [UIView]) {
    views.forEach { addSubview($0) }
  }
  public func removeAllSubviews() {
    subviews.forEach { $0.removeFromSuperview() }
  }
  public func bringToFront() {
    superview?.bringSubviewToFront(self)
  }
  public func sendToBack() {
    superview?.sendSubviewToBack(self)
  }
  public func moveAbove(_ view: UIView?) {
    guard let view, let target = superview?.subviews.firstIndex(of: view) else { return }
    while let i = superview?.subviews.firstIndex(of: self) {
      if i < target {
        superview?.exchangeSubview(at: i, withSubviewAt: i + 1)
      } else {
        break
      }
    }
  }
  public func moveBelow(_ view: UIView?, adjacent: Bool = false) {
    guard let view, let target = superview?.subviews.firstIndex(of: view) else { return }
    while let i = superview?.subviews.firstIndex(of: self) {
      if i > target {
        superview?.exchangeSubview(at: i, withSubviewAt: i - 1)
      } else {
        break
      }
    }
  }

  // 深度优先
  public func descendant<T: UIView>(_ cls: T.Type) -> T? {
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
  public func ancestor<T: UIView>(_ cls: T.Type) -> T? {
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
  public func addPushTransition(_ subtype: CATransitionSubtype, _ completion: VoidCb?) {
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
  public static func fromNib() -> Self {
    UINib(nibName: String(describing: self), bundle: Bundle(for: self))
      .instantiate(withOwner: nil, options: nil).first as? Self ?? .init()
  }
  // To use in another xib
  //   set File's Owner - Custom Class
  //   in another xib, add a sub UIView, set its Custom Class
  //   in code: awakeFromNib() { ... }
  public func loadContentFromNib() {
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

extension NSLayoutConstraint.Axis {
  public var next: Self {
    self == .vertical ? .horizontal : .vertical
  }
  public var isVertical: Bool {
    self == .vertical
  }
  public var isHorizontal: Bool {
    self == .horizontal
  }
}

extension UIStackView {
  public func addArrangedSubviews(_ views: [UIView]) {
    views.forEach { addArrangedSubview($0) }
  }
  public func removeAllArrangedSubviews() {
    arrangedSubviews.forEach { $0.removeFromSuperview() }
  }
}

extension UIViewController {
  public func addSubvc(_ child: UIViewController, _ inView: UIView?) {
    addChild(child)
    (inView ?? view).addSubview(child.view)
    child.didMove(toParent: self)
  }
  public func removeSubvc(_ child: UIViewController) {
    child.willMove(toParent: nil)
    child.view.removeFromSuperview()
    child.removeFromParent()
  }
}

extension UIView {
  public var owner: UIViewController? {
    var responder: UIResponder? = self
    while !(responder is UIViewController) {
      responder = responder?.next
      if responder == nil { break }
    }
    return (responder as? UIViewController)
  }
}
extension UIViewController {
  public var ancestor: UIViewController? {
    var ret = self
    while let vc = ret.parent {
      ret = vc
    }
    return ret
  }
}
extension UINavigationController {
  public var root: UIViewController? { viewControllers.at(0) }
  public var top: UIViewController? { topViewController }
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
