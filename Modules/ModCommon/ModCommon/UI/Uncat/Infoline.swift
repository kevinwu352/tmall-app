//
//  Infoline.swift
//  ModCommon
//
//  Created by Kevin Wu on 2022/1/1.
//

import UIKit

// class Copyline: Infoline {
//   override func setup() {
//     super.setup()
//     traiView.addSubview(copyBtn)
//   }
//   override func layoutViews() {
//     super.layoutViews()
//     copyBtn.snp.remakeConstraints { make in
//       make.trailing.equalToSuperview()
//       make.centerY.equalToSuperview()
//       make.top.greaterThanOrEqualToSuperview()
//       make.bottom.lessThanOrEqualToSuperview()
//     }
//     infoLabel.snp.remakeConstraints { make in
//       make.pin_trailing(copyBtn, -5)
//       make.leading.greaterThanOrEqualToSuperview()
//       make.centerY.equalToSuperview()
//       make.top.greaterThanOrEqualToSuperview()
//       make.bottom.lessThanOrEqualToSuperview()
//     }
//   }
//   lazy var copyBtn: UIButton = {
//     let ret = UIButton(type: .custom)
//     ret.setImage(R.image.com.icon_cross.cur, for: .normal)
//     return ret
//   }()
// }

open class Infoline: BaseStackView {
  open override func setup() {
    super.setup()
    axis = .horizontal
    alignment = .fill
    distribution = .fill
    spacing = 4
    addArrangedSubviews([leadView, midView, traiView])
    leadView.view = iconView
    midView.view = titleLabel
    traiView.addSubview(infoLabel)
  }
  open override func layoutViews() {
    super.layoutViews()
    if infoLabel.superview != nil {
      infoLabel.snp.remakeConstraints { make in
        make.trailing.equalToSuperview()
        make.leading.greaterThanOrEqualToSuperview()
        make.centerY.equalToSuperview()
        make.top.greaterThanOrEqualToSuperview()
        make.bottom.lessThanOrEqualToSuperview()
      }
    }
  }

  public struct Data {
    public var icon: Any?
    public var title: String?
    public var info: String?
    public init(icon: Any? = nil, title: String? = nil, info: String? = nil) {
      self.icon = icon
      self.title = title
      self.info = info
    }
  }
  public var data: Data? {
    didSet {
      iconView.loadImage(data?.icon)
      titleLabel.text = data?.title
      infoLabel.txt = data?.info
    }
  }

  public lazy var leadView: VerView = {
    let ret = VerView()
    ret.isHidden = true
    return ret
  }()
  public lazy var iconView: SizedImageView = {
    let ret = SizedImageView()
    //ret.kangLa(.required, .horizontal)
    //ret.kangYa(.required, .horizontal)
    return ret
  }()

  public lazy var midView: VerView = {
    let ret = VerView()
    return ret
  }()
  public lazy var titleLabel: Stylb = {
    let ret = Stylb()
    ret.setTextStyles(font: .systemFont(ofSize: 14),
                      color: .black
    )
    //ret.kangLa(.required, .horizontal)
    //ret.kangYa(.required, .horizontal)
    return ret
  }()

  public lazy var traiView: UIView = {
    let ret = UIView()
    return ret
  }()
  public lazy var infoLabel: Stylb = {
    let ret = Stylb()
    ret.setTextStyles(font: .systemFont(ofSize: 14),
                      color: .darkGray,
                      alignment: .right,
                      breakMode: .byWordWrapping
    )
    ret.numberOfLines = 0
    ret.degradeLaya(1, .horizontal)
    return ret
  }()

}
