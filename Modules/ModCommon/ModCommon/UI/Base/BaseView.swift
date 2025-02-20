//
//  BaseView.swift
//  ModCommon
//
//  Created by Kevin Wu on 2022/1/1.
//

import UIKit
import Combine

open class BaseView: UIView, Combinable {

  public lazy var cancellables = Set<AnyCancellable>()

  open override class var requiresConstraintBasedLayout: Bool { true }

  public required init?(coder: NSCoder) {
    super.init(coder: coder)
  }
  open override func awakeFromNib() {
    super.awakeFromNib()
    setup()
    layoutViews()
    bindEvents()
    loadData()
    initialized = true
    reload()
  }
  public override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
    layoutViews()
    bindEvents()
    loadData()
    initialized = true
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
  open func bindEvents() {
  }
  open func loadData() {
  }

  public func setNeedsReload() {
    setNeeds(#selector(reload))
  }
  @objc open func reload() {
  }
  public var initialized = false


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
