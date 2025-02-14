//
//  PopupViewController.swift
//  ModHomePage
//
//  Created by Kevin Wu on 2022/12/22.
//

import UIKit
import ModCommon

class PopupViewController: BaseViewController {

  override func setup() {
    super.setup()
    view.addSubview(stackView)
    stackView.addArrangedSubviews([topBtn, midBtn, botBtn])
  }

  override func layoutViews() {
    super.layoutViews()
    stackView.snp.remakeConstraints { make in
      make.center.equalToSuperview()
      make.width.equalTo(80)
    }
  }

  @objc func showTop() {
    let pop = PopBanner()
    pop.enroll()
  }

  @objc func showMid() {
    let pop = PopAlert()
    pop.enroll()
  }

  @objc func showBot() {
    let pop = PopSheet()
    pop.enroll()
  }

  lazy var stackView: UIStackView = {
    let ret = UIStackView()
    ret.axis = .vertical
    ret.alignment = .fill
    ret.distribution = .equalSpacing
    ret.spacing = 20
    return ret
  }()

  lazy var topBtn: UIButton = {
    let ret = UIButton(type: .system)
    ret.setTitle("top", for: .normal)
    ret.layer.cornerRadius = 4
    ret.layer.borderColor = UIColor.lightGray.cgColor
    ret.layer.borderWidth = 1
    ret.addTarget(self, action: #selector(showTop), for: .touchUpInside)
    return ret
  }()
  lazy var midBtn: UIButton = {
    let ret = UIButton(type: .system)
    ret.setTitle("mid", for: .normal)
    ret.layer.cornerRadius = 4
    ret.layer.borderColor = UIColor.lightGray.cgColor
    ret.layer.borderWidth = 1
    ret.addTarget(self, action: #selector(showMid), for: .touchUpInside)
    return ret
  }()
  lazy var botBtn: UIButton = {
    let ret = UIButton(type: .system)
    ret.setTitle("bot", for: .normal)
    ret.layer.cornerRadius = 4
    ret.layer.borderColor = UIColor.lightGray.cgColor
    ret.layer.borderWidth = 1
    ret.addTarget(self, action: #selector(showBot), for: .touchUpInside)
    return ret
  }()

}


class PopView: HoverView {
  override func setup() {
    super.setup()
    backgroundColor = .red
    addSubview(titleLabel)
    addSubview(descLabel)
    addSubview(stackView)
  }
  override func layoutViews() {
    super.layoutViews()
    titleLabel.snp.remakeConstraints { make in
      make.top.equalToSuperview().offset(20)
      make.centerX.equalToSuperview()
      make.height.greaterThanOrEqualTo(30)
    }
    descLabel.snp.remakeConstraints { make in
      make.pin_top(titleLabel, 5)
      make.pin_waist(10)
      make.width.equalTo(SCREEN_WID - 2 * (bubble ? 50 : 10))
    }
    stackView.snp.remakeConstraints { make in
      make.pin_top(descLabel, 5)
      make.pin_waist(10)
      make.bottom.equalToSuperview().offset(-20)
    }
  }
  var bubble = false {
    didSet {
      setRadius(bubble ? 16 : 0)
      setNeedsUpdateConstraints()
    }
  }
  @objc func cancelAction() {
    dismiss(false)
  }
  @objc func confirmAction() {
    dismiss(true)
  }
  lazy var titleLabel: UILabel = {
    let ret = UILabel()
    ret.font = .h3
    ret.textColor = .black
    ret.textAlignment = .center
    ret.lineBreakMode = .byWordWrapping
    ret.text = "Fatal Error"
    return ret
  }()
  lazy var descLabel: UILabel = {
    let ret = UILabel()
    ret.font = .primary
    ret.textColor = .black
    ret.textAlignment = .center
    ret.lineBreakMode = .byWordWrapping
    ret.numberOfLines = 0
    ret.text = "A vast range of network errors may pop up on our screen or even remain meddling in the background, which can interfere with our internet connection."
    return ret
  }()
  lazy var stackView: UIStackView = {
    let ret = UIStackView()
    ret.axis = .horizontal
    ret.alignment = .fill
    ret.distribution = .fillEqually
    ret.addArrangedSubviews([cancelBtn, confirmBtn])
    return ret
  }()
  lazy var cancelBtn: UIButton = {
    let ret = UIButton(type: .system)
    ret.setTitle("Cancel", for: .normal)
    ret.addTarget(self, action: #selector(cancelAction), for: .touchUpInside)
    return ret
  }()
  lazy var confirmBtn: UIButton = {
    let ret = UIButton(type: .system)
    ret.setTitle("Confirm", for: .normal)
    ret.addTarget(self, action: #selector(confirmAction), for: .touchUpInside)
    return ret
  }()
}

class PopBanner: PopView {
  override func setup() {
    super.setup()
    bubble = false
    attrs.banner()
    attrs.screenInteraction = .dismiss
  }
}

class PopSheet: PopView {
  override func setup() {
    super.setup()
    bubble = false
    attrs.sheet()
    attrs.screenInteraction = .dismiss
  }
}

class PopAlert: PopView {
  override func setup() {
    super.setup()
    bubble = true
    attrs.alert()
    attrs.screenInteraction = .dismiss
  }
}
