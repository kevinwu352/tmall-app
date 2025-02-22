//
//  Hud.swift
//  ModCommon
//
//  Created by Kevin Wu on 2022/1/1.
//

import UIKit
import SnapKit

public struct Hud {

  public static func activity(_ info: String?,
                              _ view: UIView? = nil
  ) {
    current?.removeFromSuperview()

    let hud = HudView.ActivityView()
    hud.info = info

    let hv = HudView()
    hv.show(hud, view, .center(0), true, nil)
    current = hv
  }

  public static func message(_ info: String?,
                             _ view: UIView? = nil,
                             _ completion: VoidCb? = nil
  ) {
    guard info?.notEmpty == true else { return }

    current?.removeFromSuperview()

    let hud = HudView.MessageView()
    hud.info = info

    let hv = HudView()
    hv.show(hud, view, .center(0), true, nil)
    masy(2) { hv.hide(true, completion) }
    current = hv
  }

  public static func hide(_ animated: Bool,
                          _ completion: VoidCb? = nil
  ) {
    current?.hide(animated, completion)
    current = nil
  }

  static weak var current: HudView?

}


class HudView: BaseView {

  override func setup() {
    super.setup()
    alpha = 0
    dimBackground = true
  }


  var contentView: UIView?

  var dimBackground = true {
    didSet { backgroundColor = dimBackground ? .hud_background : .clear }
  }


  enum Position {
    case top(_ offset: Double)
    case center(_ offset: Double)
    case bottom(_ offset: Double)
  }

  func show(_ view: UIView,
            _ inView: UIView?,
            _ position: Position,
            _ animated: Bool,
            _ completion: VoidCb?
  ) {
    guard let container = inView ?? WINDOW else { return }

    container.addSubview(self)
    snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }

    addSubview(view)
    view.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      switch position {
      case let .top(offset):
        let rect = container.convert(container.bounds, to: nil)
        if rect.minY < SAFE_TOP {
          make.top.equalToSuperview().offset(SAFE_TOP - rect.minY + offset)
        } else {
          make.top.equalToSuperview().offset(offset)
        }
      case let .center(offset):
        make.centerY.equalToSuperview().offset(offset)
      case let .bottom(offset):
        let rect = container.convert(container.bounds, to: nil)
        if rect.maxY > SCREEN_HET - SAFE_BOT {
          make.bottom.equalToSuperview().offset(SCREEN_HET - SAFE_BOT - rect.maxY + offset)
        } else {
          make.bottom.equalToSuperview().offset(offset)
        }
      }
    }
    contentView = view

    layoutIfNeeded()

    if animated {
      UIView.animate(withDuration: 0.35, delay: 0, options: .curveEaseOut) {
        self.alpha = 1
        self.contentView?.alpha = 1
      } completion: { _ in
        completion?()
      }
    } else {
      alpha = 1
      contentView?.alpha = 1
      completion?()
    }
  }

  func hide(_ animated: Bool,
            _ completion: VoidCb?
  ) {
    if animated {
      UIView.animate(withDuration: 0.35, delay: 0, options: .curveEaseIn) {
        self.contentView?.alpha = 0
        self.alpha = 0
      } completion: { _ in
        self.removeFromSuperview()
        completion?()
      }
    } else {
      removeFromSuperview()
      completion?()
    }
  }

}

extension HudView {

  class ActivityView: BaseView {
    override func setup() {
      super.setup()
      backgroundColor = .hud_bezel
      layer.cornerRadius = 5
      layer.masksToBounds = true
      addSubview(indicatorView)
    }
    override func layoutViews() {
      super.layoutViews()
      snp.makeConstraints { make in
        make.width.greaterThanOrEqualTo(snp.height)
      }
      if infoLabel.superview == nil {
        indicatorView.snp.remakeConstraints { make in
          make.edges.equalToSuperview().inset(UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15))
        }
      } else {
        indicatorView.snp.remakeConstraints { make in
          make.top.equalToSuperview().offset(15)
          make.centerX.equalToSuperview()
        }
        infoLabel.snp.remakeConstraints { make in
          make.leading.equalToSuperview().offset(15)
          make.trailing.equalToSuperview().offset(-15)
          make.bottom.equalToSuperview().offset(-15)
          make.top.equalTo(indicatorView.snp.bottom).offset(5)
          make.width.greaterThanOrEqualTo(indicatorView)
          make.width.lessThanOrEqualTo(300)
        }
      }
    }
    var info: String? {
      didSet {
        if let info = info, info.notEmpty {
          infoLabel.text = info
          addSubview(infoLabel)
        } else {
          infoLabel.removeFromSuperview()
        }
        setNeedsLayout()
      }
    }
    lazy var indicatorView: UIActivityIndicatorView = {
      let ret = UIActivityIndicatorView(style: .large)
      ret.color = .hud_content
      ret.startAnimating()
      return ret
    }()
    lazy var infoLabel: UILabel = {
      let ret = UILabel()
      ret.font = .hud_activity
      ret.textColor = .hud_content
      ret.textAlignment = .center
      return ret
    }()
  }

}

extension HudView {

  class MessageView: BaseView {
    override func setup() {
      super.setup()
      backgroundColor = .hud_bezel
      layer.cornerRadius = 5
      layer.masksToBounds = true
      addSubview(infoLabel)
    }
    override func layoutViews() {
      super.layoutViews()
      infoLabel.snp.remakeConstraints { make in
        make.edges.equalToSuperview().inset(UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15))
        make.width.lessThanOrEqualTo(300)
      }
    }
    var info: String? {
      didSet {
        infoLabel.text = info
        invalidateIntrinsicContentSize()
      }
    }
    lazy var infoLabel: UILabel = {
      let ret = UILabel()
      ret.font = .hud_message
      ret.textColor = .hud_content
      ret.textAlignment = .left
      ret.numberOfLines = 10
      return ret
    }()
  }

}


// [COLORS]
fileprivate extension UIColor {
  static var hud_background: UIColor { [UIColor(white: 50/255.0, alpha: 0.3), UIColor(white: 0, alpha: 0.5)][THEME.rawValue] }
  static var hud_bezel: UIColor { [UIColor.white.withAlphaComponent(0.6), UIColor.black.withAlphaComponent(0.6)][THEME.rawValue] }
  static var hud_content: UIColor { [UIColor.black, UIColor.white][THEME.rawValue] }
}
// [FONTS]
fileprivate extension UIFont {
  static let hud_activity = UIFont.systemFont(ofSize: 16, weight: .regular)
  static let hud_message = UIFont.systemFont(ofSize: 16, weight: .regular)
}
