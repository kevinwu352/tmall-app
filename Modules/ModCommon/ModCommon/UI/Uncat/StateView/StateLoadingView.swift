//
//  StateLoadingView.swift
//  ModCommon
//
//  Created by Kevin Wu on 2022/1/1.
//

import UIKit
import Combine
import SnapKit

public extension StateView {
  enum LoadingStyle {
    case common
  }
}

extension StateView.LoadingStyle {
  func view() -> UIView {
    switch self {
    case .common:
      return StateView.LoadingCommonView()
    }
  }
}


extension StateView {
  class LoadingCommonView: BaseView {
    override func setup() {
      super.setup()
      addSubview(contentView)
      contentView.addSubviews([indicatorView, titleLabel])
    }
    override func layoutViews() {
      super.layoutViews()
      contentView.snp.remakeConstraints { make in
        make.leading.equalToSuperview().offset(20)
        make.trailing.equalToSuperview().offset(-20)
        make.centerY.equalToSuperview()
      }
      indicatorView.snp.remakeConstraints { make in
        make.centerX.equalToSuperview()
        make.top.equalToSuperview()
      }
      titleLabel.snp.remakeConstraints { make in
        make.leading.trailing.bottom.equalToSuperview()
        make.top.equalTo(indicatorView.snp.bottom).offset(10)
      }
    }

    lazy var contentView: UIView = {
      let ret = UIView()
      return ret
    }()

    lazy var indicatorView: UIActivityIndicatorView = {
      let ret = UIActivityIndicatorView(style: .large)
      ret.startAnimating()
      ret.hidesWhenStopped = false
      ret.chg.color(.text_primary)
      return ret
    }()

    lazy var titleLabel: UILabel = {
      let ret = UILabel()
      ret.font = .primary
      ret.chg.textColor(.text_primary)
      ret.chg.text(R.string.com.state_loading_title.cur)
      ret.numberOfLines = 0
      ret.lineBreakMode = .byWordWrapping
      ret.textAlignment = .center
      return ret
    }()
  }
}
