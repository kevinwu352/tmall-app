//
//  TestViewController.swift
//  ModHomePage
//
//  Created by Kevin Wu on 2022/1/1.
//

import UIKit
import Combine
import SnapKit
import ModCommon

class TestViewController: BaseViewController {

  override func setup() {
    super.setup()
    navbar?.titleLabel.text = "Test"

  }

  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesEnded(touches, with: event)

    navigationController?.pushViewController(AppleViewController(), animated: true)

  }

}
