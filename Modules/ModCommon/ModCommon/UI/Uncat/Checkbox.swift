//
//  Checkbox.swift
//  ModCommon
//
//  Created by Kevin Wu on 2022/1/1.
//

import UIKit
import Combine
import SnapKit

public class Checkbox: BaseControl {

  public override func setup() {
    super.setup()
    chg.theme("update") { $0.reload() }

    addSubview(stackView)
    stackView.addArrangedSubviews([leadView, textLabel])
    leadView.view = imageView
    traiView = textLabel
  }
  public override func layoutViews() {
    super.layoutViews()
    stackView.snp.remakeConstraints { make in
      if hugging {
        make.edges.equalToSuperview().inset(padding)
      } else {
        make.leading.equalToSuperview().offset(padding.left)
        make.top.equalToSuperview().offset(padding.top)
        make.bottom.equalToSuperview().offset(-padding.bottom)
        make.trailing.lessThanOrEqualToSuperview().offset(-padding.right)
      }
    }
  }
  public override func reload() {
    super.reload()
    guard initialized else { return }
    if isEnabled {
      if isSelected {
        imageView.image = onEnabled()
      } else {
        imageView.image = ofEnabled()
      }
    } else {
      if isSelected {
        imageView.image = onDisabled() ?? onEnabled()
      } else {
        imageView.image = ofDisabled() ?? ofEnabled()
      }
    }
    if widen {
      stackView.addGestureRecognizer(tapRec)
      stackView.addGestureRecognizer(pressRec)
    } else {
      leadView.addGestureRecognizer(tapRec)
      leadView.addGestureRecognizer(pressRec)
    }
  }


  lazy var tapRec: UITapGestureRecognizer = {
    let ret = UITapGestureRecognizer()
    ret.cmb.publisher
      .sink { [weak self] in
        guard $0.state == .ended else { return }
        self?.on.toggle()
        self?.sendActions(for: .valueChanged)
      }
      .store(in: &cancellables)
    return ret
  }()

  lazy var pressRec: UILongPressGestureRecognizer = {
    let ret = UILongPressGestureRecognizer()
    ret.cmb.publisher
      .sink { [weak self] in
        guard $0.state == .ended else { return }
        self?.on.toggle()
        self?.sendActions(for: .valueChanged)
      }
      .store(in: &cancellables)
    return ret
  }()


  @Setted public var on = false {
    didSet { isSelected = on }
  }

  public override var isSelected: Bool {
    get { super.isSelected }
    set {
      super.isSelected = newValue
      setNeedsReload()
    }
  }

  public override var isEnabled: Bool {
    get { super.isEnabled }
    set {
      super.isEnabled = newValue
      setNeedsReload()
    }
  }

  // 响应区域是否包含文字
  public var widen = true {
    didSet { setNeedsReload() }
  }

  // 使用固有尺寸
  // 为 false 时，外部必须限制宽度，设置 width / trailing
  public var hugging: Bool {
    get { stackView.distribution == .equalSpacing }
    set {
      stackView.distribution = newValue ? .equalSpacing : .fill
      setNeedsUpdateConstraints()
      invalidateIntrinsicContentSize()
    }
  }

  public var padding: UIEdgeInsets = .zero {
    didSet {
      setNeedsUpdateConstraints()
      invalidateIntrinsicContentSize()
    }
  }

  public var ofDisabled: ()->UIImage? = { R.image.checkbox.standard_of_d.cur }
  public var ofEnabled:  ()->UIImage? = { R.image.checkbox.standard_of_e.cur }
  public var onDisabled: ()->UIImage? = { R.image.checkbox.standard_on_d.cur }
  public var onEnabled:  ()->UIImage? = { R.image.checkbox.standard_on_e.cur }


  public lazy var stackView: UIStackView = {
    let ret = UIStackView()
    ret.axis = .horizontal
    ret.alignment = .fill
    ret.distribution = .equalSpacing
    ret.spacing = 4
    return ret
  }()

  public lazy var leadView: VerView = {
    let ret = VerView()
    return ret
  }()
  public lazy var imageView: SizedImageView = {
    let ret = SizedImageView()
    ret.contentMode = .scaleAspectFit
    return ret
  }()

  public var traiView: UIView? {
    didSet {
      if oldValue == textLabel {
        oldValue?.isHidden = true
      } else {
        oldValue?.removeFromSuperview()
      }
      if let tv = traiView {
        if traiView == textLabel {
          tv.isHidden = false
        } else {
          stackView.addArrangedSubview(tv)
        }
      }
    }
  }
  public lazy var textLabel: Stylb = {
    let ret = Stylb()
    ret.setTextStyles(font: .systemFont(ofSize: 14),
                      color: .black
    )
    ret.numberOfLines = 0
    ret.degradeLaya(1, .horizontal)
    return ret
  }()
}

public extension Checkbox {
  func standard() {
    ofDisabled = { R.image.checkbox.standard_of_d.cur }
    ofEnabled  = { R.image.checkbox.standard_of_e.cur }
    onDisabled = { R.image.checkbox.standard_on_d.cur }
    onEnabled  = { R.image.checkbox.standard_on_e.cur }
    setNeedsReload()
  }
}
