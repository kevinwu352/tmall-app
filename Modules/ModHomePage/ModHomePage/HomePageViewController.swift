//
//  HomePageViewController.swift
//  ModHomePage
//
//  Created by Kevin Wu on 2022/1/1.
//

import UIKit
import Combine
import SnapKit
import ModCommon
import SwiftyJSON

class HomePageViewController: BaseViewController {

  override func setup() {
    super.setup()
    navbar?.titleLabel.text = "HomePage"
  }


  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesEnded(touches, with: event)
    navigationController?.pushViewController(AppleViewController(), animated: true)

  }

}


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
