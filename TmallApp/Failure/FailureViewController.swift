//
//  FailureViewController.swift
//  TmallApp
//
//  Created by Kevin Wu on 2022/1/1.
//

import UIKit
import SnapKit
import ModCommon

class FailureViewController: BaseViewController {

  override func setup() {
    super.setup()
    removeNavbar()
    view.addSubview(statusLabel)
  }
  override func layoutViews() {
    super.layoutViews()
    statusLabel.snp.remakeConstraints { make in
      make.center.equalToSuperview()
    }
  }

  lazy var statusLabel: UILabel = {
    let ret = UILabel()
    ret.font = UIFont.systemFont(ofSize: 14)
    ret.textColor = .red
    ret.text = "Failure"
    return ret
  }()

}
