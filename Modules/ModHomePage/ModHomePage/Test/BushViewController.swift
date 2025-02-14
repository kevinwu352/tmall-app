//
//  BushViewController.swift
//  ModHomePage
//
//  Created by Kevin Wu on 2022/1/1.
//

import UIKit
import Combine
import SnapKit
import ModCommon

class BushViewController: BaseViewController {

  override func setup() {
    super.setup()
    navbar?.titleLabel.text = "Bush"

  }

  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesEnded(touches, with: event)

    navigationController?.pushViewController(CatViewController(), animated: true)

  }

}
