//
//  ProblemOneView.swift
//  ModHomePage
//
//  Created by Kevin Wu on 3/7/25.
//

import UIKit
import ModCommon

/*
 view.addSubview(p1v)
 p1v.snp.remakeConstraints { make in
 make.centerY.equalToSuperview()
 make.leading.equalToSuperview().offset(50)
 }
 */
class ProblemOneView: BaseView {
  override func setup() {
    super.setup()
    addSubview(lb)
  }
  override func layoutViews() {
    super.layoutViews()
    lb.snp.remakeConstraints { make in
      make.leading.equalToSuperview().offset(padding.left)
      make.top.equalToSuperview().offset(padding.top)
      make.bottom.equalToSuperview().offset(-padding.bottom)
      make.trailing.lessThanOrEqualToSuperview().offset(-padding.right)
      //make.trailing.equalToSuperview().offset(-padding.right)
    }
  }
  var padding: UIEdgeInsets = .zero {
    didSet {
      setNeedsUpdateConstraints()
      invalidateIntrinsicContentSize()
    }
  }
  lazy var lb: UILabel = {
    let ret = UILabel()
    ret.font = .systemFont(ofSize: 64)
    ret.textColor = .red
    ret.text = "abc"
    return ret
  }()
}
