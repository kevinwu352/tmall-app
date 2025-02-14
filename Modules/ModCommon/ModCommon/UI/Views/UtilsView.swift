//
//  UtilsView.swift
//  ModCommon
//
//  Created by Kevin Wu on 2022/1/1.
//

import UIKit

public class SizedImageView: UIImageView {
  public var content_size: CGSize? {
    didSet { invalidateIntrinsicContentSize() }
  }
  public override var intrinsicContentSize: CGSize {
    content_size ?? super.intrinsicContentSize
  }
  public override func sizeThatFits(_ size: CGSize) -> CGSize {
    content_size ?? super.sizeThatFits(size)
  }
}


public class VerView: BaseStackView {
  public override func setup() {
    super.setup()
    axis = .horizontal
    alignment = .center
    distribution = .fill
    spacing = 0
    addArrangedSubview(container)
  }
  public override func layoutViews() {
    super.layoutViews()
    view?.snp.remakeConstraints { make in
      make.edges.equalToSuperview().inset(padding)
    }
  }
  var padding: UIEdgeInsets = .zero

  lazy var container: UIView = {
    let ret = UIView()
    return ret
  }()
  public var view: UIView? {
    didSet {
      oldValue?.removeFromSuperview()
      if let view = view {
        container.addSubview(view)
      }
      setNeedsUpdateConstraints()
      invalidateIntrinsicContentSize()
    }
  }

  public enum Position {
    case top(_ o: Double) // +增加高度 -减少高度
    case mid(_ o: Double) // +-增加两倍高度
    case bot(_ o: Double) // +减少高度 -增加高度
    var alignment: UIStackView.Alignment {
      switch self {
      case .top: return .top
      case .mid: return .center
      case .bot: return .bottom
      }
    }
    var padding: UIEdgeInsets {
      switch self {
      case let .top(o): return UIEdgeInsets(top: o, left: 0, bottom: 0, right: 0)
      case let .mid(o): return UIEdgeInsets(top: o >= 0 ? o * 2 : 0, left: 0, bottom: o >= 0 ? 0 : -o * 2, right: 0)
      case let .bot(o): return UIEdgeInsets(top: 0, left: 0, bottom: -o, right: 0)
      }
    }
  }
  public var position: Position = .mid(0) {
    didSet {
      alignment = position.alignment
      padding = position.padding
      setNeedsUpdateConstraints()
      invalidateIntrinsicContentSize()
    }
  }
}
