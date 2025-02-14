//
//  StateErrorView.swift
//  ModCommon
//
//  Created by Kevin Wu on 2022/1/1.
//

import UIKit
import Combine
import SnapKit

public extension StateView {
  enum ErrorStyle {
    case common
  }
}

extension StateView.ErrorStyle {
  func view() -> UIView {
    switch self {
    case .common:
      return StateView.ErrorCommonView()
    }
  }
}


extension StateView {
  class ErrorCommonView: BaseView {
    override func setup() {
      super.setup()
      addSubview(contentView)
      contentView.addSubviews([iconView, titleLabel])
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
        make.leading.trailing.bottom.equalToSuperview()
        make.top.equalTo(iconView.snp.bottom).offset(10)
      }
    }

    lazy var contentView: UIView = {
      let ret = UIView()
      return ret
    }()

    lazy var iconView: UIImageView = {
      let ret = UIImageView()
      ret.contentMode = .scaleAspectFit
      ret.chg.image(R.image.state.error_day.cur)
      return ret
    }()

    lazy var titleLabel: UILabel = {
      let ret = UILabel()
      ret.font = .primary
      ret.chg.textColor(.text_primary)
      ret.chg.text(R.string.com.state_error_title.cur)
      ret.numberOfLines = 0
      ret.lineBreakMode = .byWordWrapping
      ret.textAlignment = .center
      return ret
    }()
  }
}
