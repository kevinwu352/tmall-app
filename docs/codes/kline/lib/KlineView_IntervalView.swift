//
//  KlineView_IntervalView.swift
//  ModHomePage
//
//  Created by Kevin Wu on 2022/1/1.
//

import UIKit
import Combine
import SnapKit
import AppCommon

public extension KlineView {

  class IntervalView: BaseView {
    public override func setup() {
      super.setup()
      backgroundColor = "#eaeaea".clr
      addSubview(intervalStack)

      intervalList = [
        Interval.timeline,
        Interval.range_1m,
        Interval.range_15m,
        Interval.range_1h,
        Interval.range_1d,
      ].map { type -> UIButton in
        let btn = UIButton(type: .custom)
        btn.tag = type.rawValue
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        btn.setTitle(type.title, for: .normal)
        btn.setTitleColor(.lightGray, for: .normal)
        btn.setTitleColor(.black, for: .highlighted)
        btn.setTitleColor(.black, for: .disabled)
        btn.isEnabled = type != self.interval
        btn.addTarget(self, action: #selector(intervalAction(_:)), for: .touchUpInside)
        return btn
      }
      intervalStack.addArrangedSubviews(intervalList)
    }
    public override func layoutViews() {
      super.layoutViews()
      intervalStack.snp.remakeConstraints { make in
        make.top.bottom.equalToSuperview()
        make.leading.equalToSuperview().offset(20)
        make.width.equalTo(200)
      }
    }

    public private(set) var intervalList: [UIButton] = []


    public enum Interval: Int {
      case timeline
      case range_1m
      //case range_3m
      //case range_5m
      case range_15m
      //case range_30m
      case range_1h
      //case range_2h
      //case range_4h
      //case range_6h
      //case range_8h
      //case range_12h
      case range_1d
      //case range_3d
      //case range_1w
      //case range_1M
      public var title: String {
        switch self {
        case .timeline: return "TL"
        case .range_1m: return "1m"
        case .range_15m: return "15m"
        case .range_1h: return "1h"
        case .range_1d: return "1d"
        }
      }
      public var value: String {
        switch self {
        case .timeline: return "1m"
        case .range_1m: return "1m"
        case .range_15m: return "15m"
        case .range_1h: return "1h"
        case .range_1d: return "1d"
        }
      }
    }
    @Setted public var interval: Interval = .range_1m {
      didSet {
        intervalList.forEach { $0.isEnabled = $0.tag != interval.rawValue }
      }
    }


    @objc func intervalAction(_ sender: UIButton) {
      if let type = Interval(rawValue: sender.tag) {
        self.interval = type
      }
    }

    public override var intrinsicContentSize: CGSize {
      CGSize(width: UIView.noIntrinsicMetric, height: 30)
    }

    public lazy var intervalStack: UIStackView = {
      let ret = UIStackView()
      ret.axis = .horizontal
      ret.alignment = .fill
      ret.distribution = .equalSpacing
      ret.spacing = 4
      return ret
    }()
  }

}
