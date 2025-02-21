//
//  StateEmptyView.swift
//  ModCommon
//
//  Created by Kevin Wu on 2022/1/1.
//

import UIKit
import Combine
import SnapKit

public extension StateView {
  enum EmptyStyle {
    case common
  }
}

extension StateView.EmptyStyle {
  func view() -> UIView {
    switch self {
    case .common:
      return StateView.EmptyCommonView()
    }
  }
}


extension StateView {
  class EmptyCommonView: BaseView {
    override func setup() {
      super.setup()
      addSubview(contentView)
      contentView.addSubviews([iconView, titleLabel, refreshBtn])
    }
    override func layoutViews() {
      super.layoutViews()
      contentView.snp.remakeConstraints { make in
        make.leading.equalToSuperview().offset(20)
        make.trailing.equalToSuperview().offset(-20)
        make.centerY.equalToSuperview()
      }
      iconView.snp.remakeConstraints { make in
        make.centerX.equalToSuperview()
        make.top.equalToSuperview()
        make.size.equalTo(CGSize(width: 100, height: 100))
      }
      titleLabel.snp.remakeConstraints { make in
        make.leading.trailing.equalToSuperview()
        make.top.equalTo(iconView.snp.bottom).offset(10)
      }
      refreshBtn.snp.remakeConstraints { make in
        make.centerX.equalToSuperview()
        make.top.equalTo(titleLabel.snp.bottom).offset(10)
        make.bottom.equalToSuperview()
      }
    }

    lazy var contentView: UIView = {
      let ret = UIView()
      return ret
    }()

    lazy var iconView: UIImageView = {
      let ret = UIImageView()
      ret.contentMode = .scaleAspectFit
      ret.chg.image(R.image.state.empty_day.cur)
      return ret
    }()

    lazy var titleLabel: UILabel = {
      let ret = UILabel()
      ret.font = .primary
      ret.chg.textColor(.text_primary)
      ret.chg.text(R.string.com.state_empty_title.cur)
      ret.numberOfLines = 0
      ret.lineBreakMode = .byWordWrapping
      ret.textAlignment = .center
      return ret
    }()

    lazy var refreshBtn: UIButton = {
      let ret = UIButton(type: .custom)
      ret.chg.setTitle(R.string.com.state_empty_refresh.cur, .normal)
      ret.chg.setTitleColor(.text_primary, .normal)
      ret.cmb.tap
        .sink { [weak self] in (self?.superview as? StateView)?.refreshEvent.send() }
        .store(in: &cancellables)
      return ret
    }()
  }
}
