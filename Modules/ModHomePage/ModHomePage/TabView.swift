//
//  TabView.swift
//  ModHomePage
//
//  Created by Kevin Wu on 2024/05/08.
//

import UIKit
import ModCommon

class TabView: BaseView {

  override func setup() {
    super.setup()
    addSubview(stackView)
    for i in 0..<3 {
      let bt = UIButton(type: .custom)
      bt.tag = i
      bt.setTitle("\(i)\(i)\(i)", for: .normal)
      bt.setTitleColor(.blue, for: .normal)
      bt.backgroundColor = .lightGray
      bt.addTarget(self, action: #selector(buttonClicked), for: .touchUpInside)
      stackView.addArrangedSubview(bt)
    }
  }
  override func layoutViews() {
    super.layoutViews()
    stackView.snp.remakeConstraints { make in
      make.edges.equalToSuperview()
    }
  }
  override func reload() {
    super.reload()
    guard initialized else { return }

    reload(nil, false)
  }

  @objc func buttonClicked(_ sender: UIButton) {
    reset(sender.tag, true, true)
  }

  private(set) var current = 0
  var didChange: ((Int)->Void)?

  func reset(_ value: Int, _ animated: Bool, _ notify: Bool) {
    let oldValue = current
    current = value
    reload(oldValue, animated)
    if notify {
      didChange?(value)
    }
  }
  func reload(_ old: Int?, _ animated: Bool) {
    stackView.arrangedSubviews
      .compactMap { $0 as? UIButton }
      .forEach { $0.setTitleColor($0.tag == current ? .red : .blue, for: .normal) }
  }



  lazy var stackView: UIStackView = {
    let ret = UIStackView()
    ret.axis = .horizontal
    ret.alignment = .fill
    ret.distribution = .equalSpacing
    ret.spacing = 10
    return ret
  }()

}
