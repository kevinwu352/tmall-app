//
//  Drop.swift
//  ModCommon
//
//  Created by Kevin Wu on 2022/1/1.
//

import UIKit

public struct Drop {
  public static func info(_ text: String, _ completion: VoidCb? = nil) {
    DropView.display(.info, text, completion)
  }
  public static func success(_ text: String, _ completion: VoidCb? = nil) {
    DropView.display(.success, text, completion)
  }
  public static func warning(_ text: String, _ completion: VoidCb? = nil) {
    DropView.display(.warning, text, completion)
  }
  public static func error(_ text: String, _ completion: VoidCb? = nil) {
    DropView.display(.error, text, completion)
  }
}

class DropView: BaseView {

  override func setup() {
    super.setup()
    backgroundColor = state.backgroundColor
    addSubview(label)

    setupTap(nil)
  }
  override func layoutSubviews() {
    super.layoutSubviews()
    label.frame = CGRect(x: 10, y: STATUS_BAR_HET, width: SCREEN_WID-10*2, height: NAV_BAR_HET)
  }
  override var intrinsicContentSize: CGSize {
    CGSize(width: UIView.noIntrinsicMetric, height: TOP_HET)
  }
  override func sizeThatFits(_ size: CGSize) -> CGSize {
    CGSize(width: UIView.noIntrinsicMetric, height: TOP_HET)
  }


  enum State {
    case info
    case success
    case warning
    case error
    var backgroundColor: UIColor? {
      switch self {
      case .info: return UIColor(red: 52/255.0, green: 152/255.0, blue: 219/255.0, alpha: 0.9)
      case .success: return UIColor(red: 39/255.0, green: 174/255.0, blue: 96/255.0, alpha: 0.9)
      case .warning: return UIColor(red: 241/255.0, green: 196/255.0, blue: 15/255.0, alpha: 0.9)
      case .error: return UIColor(red: 192/255.0, green: 57/255.0, blue: 43/255.0, alpha: 0.9)
      }
    }
  }
  var state: State = .info {
    didSet { backgroundColor = state.backgroundColor }
  }


  static func display(_ state: State, _ text: String, _ completion: VoidCb?) {
    let dv = DropView()
    dv.state = state
    dv.label.text = text
    dv.show(true, nil)
    dv.delayHide(4, true, completion)
  }

  func show(_ animated: Bool, _ completion: VoidCb?) {
    if animated {
      frame = CGRect(x: 0, y: -TOP_HET, width: SCREEN_WID, height: TOP_HET)
      layoutIfNeeded()
      WINDOW?.addSubview(self)
      UIView.animate(withDuration: 0.15, delay: 0, options: [.allowUserInteraction, .curveEaseOut]) {
        self.frame = CGRect(x: 0, y: 0, width: SCREEN_WID, height: TOP_HET)
      } completion: { _ in
        completion?()
      }
    } else {
      WINDOW?.addSubview(self)
      frame = CGRect(x: 0, y: 0, width: SCREEN_WID, height: TOP_HET)
      completion?()
    }
  }
  func hide(_ animated: Bool, _ completion: VoidCb?) {
    if animated {
      UIView.animate(withDuration: 0.15, delay: 0, options: [.allowUserInteraction, .curveEaseIn]) {
        self.frame = CGRect(x: 0, y: -TOP_HET, width: SCREEN_WID, height: TOP_HET)
      } completion: { _ in
        self.removeFromSuperview()
        completion?()
      }
    } else {
      removeFromSuperview()
      completion?()
    }
  }


  func delayHide(_ time: Double, _ animated: Bool, _ completion: VoidCb?) {
    hideWork = masy(time) { [weak self] in self?.hide(animated, completion) }
  }
  func cancelDelayHide() {
    hideWork = nil
  }
  var hideWork: DispatchWorkItem? {
    didSet { oldValue?.cancel() }
  }

  override func tapped(_ sender: UIGestureRecognizer) {
    super.tapped(sender)
    guard sender.state == .ended else { return }
    cancelDelayHide()
    hide(true, nil)
  }


  lazy var label: UILabel = {
    let ret = UILabel()
    ret.numberOfLines = 2
    ret.textAlignment = .center
    ret.lineBreakMode = .byTruncatingTail
    ret.font = UIFont.systemFont(ofSize: 17)
    ret.textColor = .white
    return ret
  }()
}


// [COLORS]

// [FONTS]
