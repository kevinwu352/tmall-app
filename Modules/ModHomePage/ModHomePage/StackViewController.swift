//
//  StackViewController.swift
//  ModHomePage
//
//  Created by Kevin Wu on 11/16/24.
//

import UIKit
import ModCommon

/*
fill
 stack 宽度不限时，每个 item 等于各自宽度
 stack 限宽且内容不够宽时，如果优先级相同，会拉出约束问题
 stack 限宽且内容足够宽时，如果优先级相同，会压出约束问题

fillEqually
 stack 宽度不限时，每个 item 宽度相同，等于最宽那个

fillProportionally
 stack 宽度不限时，每个 item 等于各自宽度

equalSpacing
 stack 宽度不限时，每个 item 等于各自宽度，有约束问题
 stack 限宽且内容不够宽时，spacing 失效（不应该限宽）
 stack 限宽且内容足够宽时，如果优先级相同，会压出约束问题（不应该限宽）

equalCentering
*/

class StackViewController: BaseViewController {

  override func setup() {
    super.setup()
    view.addSubviews([action1, stack1])
    view.addSubviews([action2, stack2])

    action1.axis = stack1.axis
    action1.distribution = stack1.distribution
    action1.alignment = stack1.alignment

    action2.axis = stack2.axis
    action2.distribution = stack2.distribution
    action2.alignment = stack2.alignment


    stack1.addArrangedSubviews([lb("an"), lb("anan")])
    stack1.addArrangedSubview(lb("ananan"))
    stack1.addArrangedSubview(lb("variations of gray or grey include achromatic grayscale"))

    stack2.addArrangedSubviews([lb("an"), lb("anan")])
    stack2.addArrangedSubview(lb("ananan"))
    stack2.addArrangedSubview(lb("variations of gray or grey include achromatic grayscale"))
  }
  override func layoutViews() {
    super.layoutViews()
    action1.snp.remakeConstraints { make in
      make.pin_top(navbar, 0)
      make.leading.trailing.equalToSuperview()
    }
    stack1.snp.remakeConstraints { make in
      make.pin_top(action1, 10)
      make.leading.equalToSuperview().offset(10)
      make.trailing.equalToSuperview().offset(-10)
      make.height.equalTo(100)
    }

    action2.snp.remakeConstraints { make in
      make.pin_top(navbar, 200)
      make.leading.trailing.equalToSuperview()
    }
    stack2.snp.remakeConstraints { make in
      make.pin_top(action2, 10)
      make.leading.equalToSuperview().offset(10)
      make.trailing.equalToSuperview().offset(-10)
      make.height.equalTo(70)
    }
  }
  override func bindEvents() {
    super.bindEvents()
    action1.$axis
      .dropFirst()
      .compactMap { $0 }
      .assign(to: \.axis, on: stack1)
      .store(in: &cancellables)
    action1.$distribution
      .dropFirst()
      .compactMap { $0 }
      .assign(to: \.distribution, on: stack1)
      .store(in: &cancellables)
    action1.$alignment
      .dropFirst()
      .compactMap { $0 }
      .assign(to: \.alignment, on: stack1)
      .store(in: &cancellables)

    action2.$axis
      .dropFirst()
      .compactMap { $0 }
      .assign(to: \.axis, on: stack2)
      .store(in: &cancellables)
    action2.$distribution
      .dropFirst()
      .compactMap { $0 }
      .assign(to: \.distribution, on: stack2)
      .store(in: &cancellables)
    action2.$alignment
      .dropFirst()
      .compactMap { $0 }
      .assign(to: \.alignment, on: stack2)
      .store(in: &cancellables)
  }

  lazy var action1: ActionView = {
    let ret = ActionView()
    return ret
  }()
  lazy var stack1: UIStackView = {
    let ret = UIStackView()
    ret.axis = .horizontal
    ret.distribution = .fill
    ret.alignment = .fill
    ret.spacing = 10
    ret.backgroundColor = UIColor(hex: 0xf0f0f0)
    return ret
  }()

  lazy var action2: ActionView = {
    let ret = ActionView()
    return ret
  }()
  lazy var stack2: UIStackView = {
    let ret = UIStackView()
    ret.axis = .vertical
    ret.distribution = .fill
    ret.alignment = .fill
    ret.spacing = 10
    ret.backgroundColor = UIColor(hex: 0xf0f0f0)
    return ret
  }()

  func lb(_ str: String?) -> UILabel {
    let ret = UILabel()
    ret.backgroundColor = .rand()
    ret.font = UIFont.systemFont(ofSize: 14)
    ret.textColor = .black
    ret.text = str
    return ret
  }

  class ActionView: BaseView {
    override func setup() {
      super.setup()
      addSubviews([axisSeg, alignmentSeg, distributionSeg])
    }
    override func layoutViews() {
      super.layoutViews()
      axisSeg.snp.remakeConstraints { make in
        make.leading.top.equalToSuperview()
        make.width.equalToSuperview().multipliedBy(2.0/7.0)
      }
      distributionSeg.snp.remakeConstraints { make in
        make.trailing.top.equalToSuperview()
        make.pin_leading(axisSeg, 0)
      }
      alignmentSeg.snp.remakeConstraints { make in
        make.leading.trailing.bottom.equalToSuperview()
        make.pin_top(axisSeg, 0)
      }
    }
    @Setted var axis: NSLayoutConstraint.Axis? {
      didSet {
        if axis == .vertical {
          axisSeg.selectedSegmentIndex = 0
        } else if axis == .horizontal {
          axisSeg.selectedSegmentIndex = 1
        }
      }
    }
    @Setted var distribution: UIStackView.Distribution? {
      didSet {
        if distribution == .fill {
          distributionSeg.selectedSegmentIndex = 0
        } else if distribution == .fillEqually {
          distributionSeg.selectedSegmentIndex = 1
        } else if distribution == .fillProportionally {
          distributionSeg.selectedSegmentIndex = 2
        } else if distribution == .equalSpacing {
          distributionSeg.selectedSegmentIndex = 3
        } else if distribution == .equalCentering {
          distributionSeg.selectedSegmentIndex = 4
        }
      }
    }
    @Setted var alignment: UIStackView.Alignment? {
      didSet {
        if alignment == .fill {
          alignmentSeg.selectedSegmentIndex = 0
        } else if alignment == .leading {
          alignmentSeg.selectedSegmentIndex = 1
        } else if alignment == .center {
          alignmentSeg.selectedSegmentIndex = 2
        } else if alignment == .trailing {
          alignmentSeg.selectedSegmentIndex = 3
        } else if alignment == .top {
          alignmentSeg.selectedSegmentIndex = 4
        } else if alignment == .bottom {
          alignmentSeg.selectedSegmentIndex = 5
        } else if alignment == .firstBaseline {
          alignmentSeg.selectedSegmentIndex = 6
        } else if alignment == .lastBaseline {
          alignmentSeg.selectedSegmentIndex = 7
        }
      }
    }
    @objc func valueChanged(_ sender: UISegmentedControl) {
      let i = sender.selectedSegmentIndex
      if sender.tag == 0 {
        if i == 0 {
          axis = .vertical
        } else if i == 1 {
          axis = .horizontal
        }
      } else if sender.tag == 1 {
        if i == 0 {
          distribution = .fill
        } else if i == 1 {
          distribution = .fillEqually
        } else if i == 2 {
          distribution = .fillProportionally
        } else if i == 3 {
          distribution = .equalSpacing
        } else if i == 4 {
          distribution = .equalCentering
        }
      } else if sender.tag == 2 {
        if i == 0 {
          alignment = .fill
        } else if i == 1 {
          alignment = .leading
        } else if i == 2 {
          alignment = .center
        } else if i == 3 {
          alignment = .trailing
        } else if i == 4 {
          alignment = .top
        } else if i == 5 {
          alignment = .bottom
        } else if i == 6 {
          alignment = .firstBaseline
        } else if i == 7 {
          alignment = .lastBaseline
        }
      }
    }
    lazy var axisSeg: UISegmentedControl = {
      let ret = UISegmentedControl(items: ["ver", "hor"])
      ret.tag = 0
      ret.addTarget(self, action: #selector(valueChanged), for: .valueChanged)
      return ret
    }()
    lazy var distributionSeg: UISegmentedControl = {
      let ret = UISegmentedControl(items: ["fill", "f-equal", "f-proportion", "e-space", "e-center"])
      ret.tag = 1
      ret.addTarget(self, action: #selector(valueChanged), for: .valueChanged)
      return ret
    }()
    lazy var alignmentSeg: UISegmentedControl = {
      let ret = UISegmentedControl(items: ["fill", "lead", "center", "trail", "top", "bot", "first", "last"])
      ret.tag = 2
      ret.addTarget(self, action: #selector(valueChanged), for: .valueChanged)
      return ret
    }()
  }
}
