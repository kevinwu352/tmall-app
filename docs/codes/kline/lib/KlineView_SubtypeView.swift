//
//  KlineView_SubtypeView.swift
//  ModHomePage
//
//  Created by Kevin Wu on 2022/1/1.
//

import UIKit
import Combine
import SnapKit
import AppCommon

public extension KlineView {

  class SubtypeView: BaseView {
    public override func setup() {
      super.setup()
      backgroundColor = "#eaeaea".clr
      addSubview(primaryStack)
      addSubview(secondaryStack)

      primaryList = [
        Primary.ma,
        Primary.ema,
        Primary.boll,
      ].map { type -> UIButton in
        let btn = UIButton(type: .custom)
        btn.tag = type.rawValue
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        btn.setTitle(type.title, for: .normal)
        btn.setTitleColor(.lightGray, for: .normal)
        btn.setTitleColor(.black, for: .highlighted)
        btn.setTitleColor(.black, for: .disabled)
        btn.isEnabled = type != self.primary
        btn.addTarget(self, action: #selector(primaryAction(_:)), for: .touchUpInside)
        return btn
      }
      primaryStack.addArrangedSubviews(primaryList)

      secondaryList = [
        Secondary.vol,
        Secondary.macd,
        Secondary.kdj,
        Secondary.rsi,
      ].map { type -> UIButton in
        let btn = UIButton(type: .custom)
        btn.tag = type.rawValue
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        btn.setTitle(type.title, for: .normal)
        btn.setTitleColor(.lightGray, for: .normal)
        btn.setTitleColor(.black, for: .highlighted)
        btn.setTitleColor(.black, for: .disabled)
        btn.isEnabled = type != self.secondary
        btn.addTarget(self, action: #selector(secondaryAction(_:)), for: .touchUpInside)
        return btn
      }
      secondaryStack.addArrangedSubviews(secondaryList)
    }
    public override func layoutViews() {
      super.layoutViews()
      primaryStack.snp.remakeConstraints { make in
        make.top.bottom.equalToSuperview()
        make.leading.equalToSuperview().offset(20)
        make.width.equalTo(120)
      }
      secondaryStack.snp.remakeConstraints { make in
        make.top.bottom.equalToSuperview()
        make.trailing.equalToSuperview().offset(-20)
        make.width.equalTo(160)
      }
    }

    public private(set) var primaryList: [UIButton] = []

    public private(set) var secondaryList: [UIButton] = []


    public enum Primary: Int {
      case ma
      case ema
      case boll
      public var title: String {
        switch self {
        case .ma: return "MA"
        case .ema: return "EMA"
        case .boll: return "BOLL"
        }
      }
    }
    @Setted public var primary: Primary = .ma {
      didSet {
        primaryList.forEach { $0.isEnabled = $0.tag != primary.rawValue }
      }
    }

    public enum Secondary: Int {
      case vol
      case macd
      case kdj
      case rsi
      public var title: String {
        switch self {
        case .vol: return "VOL"
        case .macd: return "MACD"
        case .kdj: return "KDJ"
        case .rsi: return "RSI"
        }
      }
    }
    @Setted public var secondary: Secondary = .vol {
      didSet {
        secondaryList.forEach { $0.isEnabled = $0.tag != secondary.rawValue }
      }
    }


    @objc func primaryAction(_ sender: UIButton) {
      if let type = Primary(rawValue: sender.tag) {
        self.primary = type
      }
    }

    @objc func secondaryAction(_ sender: UIButton) {
      if let type = Secondary(rawValue: sender.tag) {
        self.secondary = type
      }
    }

    public override var intrinsicContentSize: CGSize {
      CGSize(width: UIView.noIntrinsicMetric, height: 30)
    }

    public lazy var primaryStack: UIStackView = {
      let ret = UIStackView()
      ret.axis = .horizontal
      ret.alignment = .fill
      ret.distribution = .equalSpacing
      ret.spacing = 4
      return ret
    }()

    public lazy var secondaryStack: UIStackView = {
      let ret = UIStackView()
      ret.axis = .horizontal
      ret.alignment = .fill
      ret.distribution = .equalSpacing
      ret.spacing = 4
      return ret
    }()
  }

}
