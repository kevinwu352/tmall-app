//
//  BaseView.swift
//  ModCommon
//
//  Created by Kevin Wu on 2022/1/1.
//

import UIKit
import Combine

open class BaseView: UIView, Combinable {

  public required init?(coder: NSCoder) {
    super.init(coder: coder)
  }
  open override func awakeFromNib() {
    super.awakeFromNib()
    setup()
    layoutViews()
    loadData()
    reload()
  }
  public override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
    layoutViews()
    loadData()
    reload()
  }
  open override func updateConstraints() {
    layoutViews()
    super.updateConstraints()
  }

  open func setup() {
  }
  open func layoutViews() {
  }
  open func loadData() {
  }
  @objc open func reload() {
  }
  public func setNeedsReload() {
    NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(reload), object: nil)
    perform(#selector(reload), with: nil, afterDelay: 0)
  }

  public lazy var cancellables = Set<AnyCancellable>()




  // 不管是用 init/xib 创建实例，拿到实例时，上面三个函数已经调用完成，所以 initialized 没必须，删掉
  // ViewController 需要 initialized，因为从 init() - viewDidLoad() 之间可以改变属性
  public var initialized = true

  // 基于约束的布局是懒触发的，只有在添加了约束的情况下，系统才会自动调用 -updateConstraints 方法，如果把所有的约束放在 updateConstraints 中，那么系统将会不知道你的布局方式是基于约束的，所以重写 +requiresConstraintBasedLayout 返回 YES 就是明确告诉系统：虽然我之前没有添加约束，但我确实是基于约束的布局，这样可以保证系统一定会调用 -updateConstraints 方法，从而正确添加约束
  open override class var requiresConstraintBasedLayout: Bool { true } // 不要这个方法

  open func bindEvents() { // 不要这个方法
  }


  public func setupTap(_ to: UIView?) {
    (to ?? self).addGestureRecognizer(tapRec)
  }
  public lazy var tapRec: UITapGestureRecognizer = {
    let ret = UITapGestureRecognizer(target: self, action: #selector(tapped))
    return ret
  }()
  @objc open func tapped(_ sender: UIGestureRecognizer) {
    guard sender.state == .ended else { return }
  }

  public func setupPress(_ to: UIView?) {
    (to ?? self).addGestureRecognizer(pressRec)
  }
  public lazy var pressRec: UILongPressGestureRecognizer = {
    let ret = UILongPressGestureRecognizer(target: self, action: #selector(pressed))
    return ret
  }()
  @objc open func pressed(_ sender: UIGestureRecognizer) {
  }

}
