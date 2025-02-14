//
//  Navbar.swift
//  ModCommon
//
//  Created by Kevin Wu on 2022/1/1.
//

import UIKit
import Combine
import SnapKit

public class Navbar: BaseView {

  public override func setup() {
    super.setup()
    chg.backgroundColor(.nav_background)

    addSubviews([backgroundView, contentView])
    contentView.addSubviews([imageView, titleLabel, leadingStack, trailingStack])

    setContentHuggingPriority(.required, for: .horizontal)
    setContentHuggingPriority(.required, for: .vertical)
    setContentCompressionResistancePriority(.required, for: .horizontal)
    setContentCompressionResistancePriority(.required, for: .vertical)
  }
  public override func layoutViews() {
    super.layoutViews()
    backgroundView.snp.remakeConstraints { make in
      make.edges.equalToSuperview()
    }

    contentView.snp.remakeConstraints { make in
      make.leading.trailing.bottom.equalToSuperview()
      make.height.equalTo(content_height)
    }
    imageView.snp.remakeConstraints { make in
      make.edges.equalToSuperview()
    }
    leadingStack.snp.remakeConstraints { make in
      make.top.bottom.equalToSuperview()
      make.leading.equalToSuperview().offset(leading_margin_h)
    }
    trailingStack.snp.remakeConstraints { make in
      make.top.bottom.equalToSuperview()
      make.trailing.equalToSuperview().offset(-trailing_margin_h)
    }
    titleLabel.snp.remakeConstraints { make in
      make.center.equalToSuperview()
      make.leading.greaterThanOrEqualTo(leadingStack.snp.trailing).offset(title_margin_h)
      make.trailing.lessThanOrEqualTo(trailingStack.snp.leading).offset(-title_margin_h)
    }
  }


  // MARK: Back

  public func addBackIfNeeded(_ backable: Bool) {
    guard backable else { return }
    leadingStack.removeAllArrangedSubviews()
    leadingStack.addArrangedSubview(backBtn)
  }
  public var backAction: VoidCb?
  public lazy var backEvent = PassthroughSubject<Void,Never>()


  // MARK: Layout

  public var title_margin_h = 5.0 {
    didSet { setNeedsUpdateConstraints() }
  }
  public var leading_margin_h = 10.0 {
    didSet { setNeedsUpdateConstraints() }
  }
  public var trailing_margin_h = 10.0 {
    didSet { setNeedsUpdateConstraints() }
  }

  public var padding_top: Double = STATUS_BAR_HET {
    didSet {
      setNeedsUpdateConstraints()
      invalidateIntrinsicContentSize()
    }
  }
  public var content_height: Double = NAV_BAR_HET {
    didSet {
      setNeedsUpdateConstraints()
      invalidateIntrinsicContentSize()
    }
  }

  public override var intrinsicContentSize: CGSize {
    CGSize(width: SCREEN_WID, height: padding_top + content_height)
  }
  public override func sizeThatFits(_ size: CGSize) -> CGSize {
    CGSize(width: SCREEN_WID, height: padding_top + content_height)
  }


  // =============================================================================
  // MARK: Views

  public lazy var backgroundView: UIImageView = {
    let ret = UIImageView()
    ret.chg.backgroundColor(.nav_background)
    return ret
  }()

  public lazy var contentView: UIView = {
    let ret = UIView()
    return ret
  }()

  public lazy var imageView: UIImageView = {
    let ret = UIImageView()
    return ret
  }()

  public lazy var titleLabel: UILabel = {
    let ret = UILabel()
    ret.textAlignment = .center
    ret.lineBreakMode = .byTruncatingMiddle
    ret.font = .nav_title
    ret.chg.textColor(.nav_title)
    ret.degradeLaya(1, nil)
    return ret
  }()

  public lazy var leadingStack: UIStackView = {
    let ret = UIStackView()
    ret.axis = .horizontal
    ret.alignment = .fill
    ret.distribution = .equalSpacing
    ret.spacing = 0
    ret.addArrangedSubview(UILabel())
    return ret
  }()

  public lazy var trailingStack: UIStackView = {
    let ret = UIStackView()
    ret.axis = .horizontal
    ret.alignment = .fill
    ret.distribution = .equalSpacing
    ret.spacing = 0
    ret.addArrangedSubview(UILabel())
    return ret
  }()

  public lazy var backBtn: UIButton = {
    let ret = UIButton(configuration: .plain())
    ret.configurationUpdateHandler = {
      var config = $0.configuration
      config?.image = R.image.navbar.back_day.cur
      config?.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8)
      $0.configuration = config
    }
    ret.chg.theme { $0.setNeedsUpdateConfiguration() }
    ret.cmb.tap
      .sink { [weak self] in
        self?.backAction?()
        self?.backEvent.send()
      }
      .store(in: &cancellables)
    return ret
  }()

}


// [COLORS]
extension UIColor {
  static var nav_background: UIColor { [UIColor(hex: 0xf1f3f8), UIColor(hex: 0x0d1626)][THEME.rawValue] }
  static var nav_title: UIColor { [UIColor(hex: 0x1f3f59), UIColor(hex: 0xd8e1f0)][THEME.rawValue] }
}
// [FONTS]
extension UIFont {
  static let nav_title = UIFont.systemFont(ofSize: 18, weight: .bold)
}


public extension UIViewController {

  var navbar: Navbar? {
    view.subviews.first(where: { $0 is Navbar }) as? Navbar
  }

  func addNavbar() {
    guard navbar == nil else { return }

    let nb = Navbar()
    view.addSubview(nb)
    nb.snp.remakeConstraints { make in
      make.leading.trailing.top.equalToSuperview()
    }
    nb.kangLa(.required, nil)
    nb.kangYa(.required, nil)

    nb.backAction = { [weak self] in
      self?.backSelf(true)
    }
  }

  func removeNavbar() {
    navbar?.removeFromSuperview()
  }


  func showNavbar(_ animated: Bool,
                  _ layout: ((ConstraintMaker)->Void)? = nil // CLOS
  ) { // FUNC
    navbar?.isHidden = false
    if let layout = layout {
      navbar?.snp.remakeConstraints(layout)
    } else {
      navbar?.snp.remakeConstraints { make in
        make.leading.trailing.top.equalToSuperview()
      }
    }
    if animated {
      UIView.animate(withDuration: 0.35, delay: 0, options: [.allowUserInteraction, .curveEaseOut]) {
        self.view.layoutIfNeeded()
      } completion: { _ in
        // ...
      }
    }
  }

  func hideNavbar(_ animated: Bool,
                  _ layout: ((ConstraintMaker)->Void)? = nil // CLOS
  ) { // FUNC
    if let layout = layout {
      navbar?.snp.remakeConstraints(layout)
    } else {
      navbar?.snp.remakeConstraints { make in
        make.leading.trailing.equalToSuperview()
        make.bottom.equalTo(view.snp.top)
      }
    }
    if animated {
      UIView.animate(withDuration: 0.35, delay: 0, options: [.allowUserInteraction, .curveEaseIn]) {
        self.view.layoutIfNeeded()
      } completion: { _ in
        self.navbar?.isHidden = true
      }
    } else {
      navbar?.isHidden = true
    }
  }

}
