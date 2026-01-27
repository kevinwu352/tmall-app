//
//  ViewController.swift
//  contest
//
//  Created by Kevin Wu on 1/25/26.
//

import UIKit

class ViewController: UIViewController {

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    present(ActorViewController(), animated: true)
  }

}
