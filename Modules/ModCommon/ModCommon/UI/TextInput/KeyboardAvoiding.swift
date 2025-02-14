//
//  KeyboardAvoiding.swift
//  ModCommon
//
//  Created by Kevin Wu on 2022/1/1.
//

import UIKit

// avoidView 是被移动的视图，里面一定要有输入框，输入框的位置用来算移动距离，移动 avoidView 使输入框显示出来
//
// 在 viewWillDisappear 中收起键盘，因为如果是前往下一页，最好先让本页的布局回归正常
// 在 viewWillDisappear 中 reset 是可选的，如果不 reset，唯一会出现的问题是一些约束被保留，下次 set 时才会被释放

// override func viewDidAppear(_ animated: Bool) {
//   super.viewDidAppear(animated)
//   KeyboardAvoiding.shared.avoid(tableView, 10)
// }
// override func viewWillDisappear(_ animated: Bool) {
//   super.viewWillDisappear(animated)
//   UIApplication.shared.hideKeyboard()
//   KeyboardAvoiding.shared.reset()
// }

// let formView = FormView(30)
// view.addSubview(formView)
// formView.snp.remakeConstraints { make in
//   make.top.equalToSuperview()
//   make.leading.trailing.equalToSuperview()
// }
// formView.snp.remakeConstraints { make in
//   make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
//   make.leading.trailing.equalToSuperview()
// }
// formView.snp.remakeConstraints { make in
//   make.top.equalToSuperview().offset(50)
//   make.leading.trailing.equalToSuperview()
// }

// let scrollView = UIScrollView()
// view.addSubview(scrollView)
// scrollView.addSubview(formView)
// scrollView.snp.remakeConstraints { make in
//   make.edges.equalToSuperview()
// }
// scrollView.snp.remakeConstraints { make in
//   make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
//   make.leading.trailing.bottom.equalToSuperview()
// }
// scrollView.snp.remakeConstraints { make in
//   make.top.equalToSuperview().offset(50)
//   make.leading.trailing.bottom.equalToSuperview()
// }
// formView.snp.remakeConstraints { make in
//   make.edges.equalToSuperview()
//   make.width.equalToSuperview()
// }

// class FormView: UIView {
//   convenience init(_ count: Int) {
//     self.init(frame: .zero)
//     let views = (1...count).map { LineView($0) }
//     var prev: UIView?
//     for view in views {
//       addSubview(view)
//       view.snp.remakeConstraints { make in
//         make.leading.trailing.equalToSuperview()
//         if let prev = prev {
//           make.top.equalTo(prev.snp.bottom)
//         } else {
//           make.top.equalToSuperview()
//         }
//       }
//       prev = view
//     }
//     prev?.snp.makeConstraints { make in
//       make.bottom.equalToSuperview()
//     }
//   }
//   override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//     super.touchesBegan(touches, with: event)
//     UIApplication.shared.hideKeyboard()
//   }
//   class LineView: UIView {
//     convenience init(_ index: Int) {
//       self.init(frame: .zero)
//       backgroundColor = UIColor(red: Double.random(in: 0...255)/255,
//                                 green: Double.random(in: 0...255)/255,
//                                 blue: Double.random(in: 0...255)/255,
//                                 alpha: 1)
//       let label = UILabel()
//       label.text = "\(index)"
//       label.textAlignment = .right
//       addSubview(label)
//       label.snp.remakeConstraints { make in
//         make.leading.top.bottom.equalToSuperview()
//         make.width.equalTo(50)
//       }
//       let field = UITextField()
//       field.backgroundColor = .white
//       addSubview(field)
//       field.snp.remakeConstraints { make in
//         make.trailing.equalToSuperview()
//         make.top.equalToSuperview()
//         make.bottom.equalToSuperview().offset(-1)
//         make.leading.equalTo(label.snp.trailing).offset(5)
//       }
//     }
//     override var intrinsicContentSize: CGSize {
//       CGSize(width: UIView.noIntrinsicMetric, height: 50)
//     }
//   }
// }

public class KeyboardAvoiding {

  public static let shared: KeyboardAvoiding = {
    let ret = KeyboardAvoiding()
    ret.setup()
    return ret
  }()

  func setup() {
    NotificationCenter.default
      .addObserver(forName: UIApplication.keyboardWillChangeFrameNotification, object: nil, queue: .main) { [weak self] in
        self?.reload($0)
      }
  }

  weak var avoidView: UIView?
  var keyboardSpacing = 0.0

  var constraints: [NSLayoutConstraint:Double] = [:]
  var displacement = 0.0

  var notification: Notification?

  public func avoid(_ avoid: UIView?, _ spacing: Double) {
    if avoid != avoidView {
      hide()

      constraints = findConstraints(avoid)
      displacement = 0

      notification = nil
    }

    avoidView = avoid
    keyboardSpacing = spacing

    reload(notification)
  }

  public func reset() {
    avoidView = nil
    keyboardSpacing = 0

    constraints = [:]
    displacement = 0

    notification = nil
  }



  func reload(_ noti: Notification?) {
    guard let avoidView = avoidView, avoidView.superview != nil else { return }
    notification = noti
    if let keyboardFrame = notification?.keyboardFrame {
      if keyboardFrame.minY < UIScreen.main.bounds.height {
        show()
      } else {
        hide()
      }
    }
  }

  func show() {
    guard let avoidView = avoidView, avoidView.superview != nil else { return }
    guard let notification = notification else { return }

    var offset = 0.0

    if let responder = findResponder(avoidView) {
      var avoidRect = responder.convert(responder.bounds, to: nil)
      avoidRect.origin.y -= displacement
      avoidRect.size.height += keyboardSpacing

      if let keyboardFrame = notification.keyboardFrame {
        if avoidRect.maxY > keyboardFrame.minY {
          offset = -(avoidRect.maxY - keyboardFrame.minY)
        }
      }
    }

    animate(offset, notification.keyboardAnimationOptions, notification.keyboardAnimationDuration)
  }

  func hide() {
    animate(0, notification?.keyboardAnimationOptions, notification?.keyboardAnimationDuration)
  }

  func animate(_ offset: Double,
               _ options: UIView.AnimationOptions? = nil,
               _ duration: TimeInterval? = nil
  ) { // FUNC
    guard let avoidView = avoidView, avoidView.superview != nil else { return }

    displacement = offset

    let animationOptions = options ?? [.layoutSubviews, .allowUserInteraction, .beginFromCurrentState]
    let animationDuration = duration ?? 0.25

    if constraints.isEmpty {
      UIView.animate(withDuration: animationDuration, delay: 0, options: animationOptions) {
        if offset < 0 {
          avoidView.transform = CGAffineTransform.identity.translatedBy(x: 0, y: offset)
        } else {
          avoidView.transform = CGAffineTransform.identity
        }
      }
    } else {
      for (constraint, constant) in constraints {
        if offset < 0 {
          constraint.constant = constant + offset
        } else {
          constraint.constant = constant
        }
      }
      UIView.animate(withDuration: animationDuration, delay: 0, options: animationOptions) {
        avoidView.superview?.layoutIfNeeded()
      }
    }
  }


  func findConstraints(_ view: UIView?) -> [NSLayoutConstraint:Double] {
    guard let view = view else { return [:] }

    var dict: [NSLayoutConstraint:Double] = [:]

    let constraints = view.superview?.constraints ?? []
    for constraint in constraints {
      if let firstItem = constraint.firstItem as? UIView, firstItem == view {
        if constraint.firstAttribute == .top || constraint.firstAttribute == .centerY || constraint.firstAttribute == .bottom {
          dict[constraint] = constraint.constant
        }
      }
      if let secondItem = constraint.secondItem as? UIView, secondItem == view {
        if constraint.secondAttribute == .top || constraint.secondAttribute == .centerY || constraint.secondAttribute == .bottom {
          dict[constraint] = constraint.constant
        }
      }
    }

    return dict
  }

  func findResponder(_ view: UIView) -> UIView? {
    for subview in view.subviews {
      if subview.isFirstResponder {
        return subview
      } else {
        if let responder = findResponder(subview) {
          return responder
        }
      }
    }
    return nil
  }

}


extension Notification {

  var keyboardFrame: CGRect? {
    if let value = userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
      return value.cgRectValue
    } else {
      return nil
    }
  }

  var keyboardAnimationOptions: UIView.AnimationOptions? {
    if let value = userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt {
      return UIView.AnimationOptions(rawValue: value)
    } else {
      return nil
    }
  }

  var keyboardAnimationDuration: TimeInterval? {
    if let value = userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval {
      return value
    } else {
      return nil
    }
  }

}
