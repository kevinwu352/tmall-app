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

class HomePageViewController: BaseViewController {
  override func setup() {
    super.setup()
    navbar?.titleLabel.text = "HomePage"
  }
  override func layoutViews() {
    super.layoutViews()
  }
  override func bindEvents() {
    super.bindEvents()
  }


  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesEnded(touches, with: event)
    navigationController?.pushViewController(AppleViewController(), animated: true)

  }
}
