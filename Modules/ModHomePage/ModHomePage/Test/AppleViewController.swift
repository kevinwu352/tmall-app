//
//  AppleViewController.swift
//  ModHomePage
//
//  Created by Kevin Wu on 2022/1/1.
//

import UIKit
import Combine
import SnapKit
import ModCommon

class AppleViewController: BaseViewController {

  override func setup() {
    super.setup()
    navbar?.titleLabel.text = "Apple"

  }

  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesEnded(touches, with: event)

    navigationController?.pushViewController(BushViewController(), animated: true)

  }

}
