//
//  BaseTableViewCell.swift
//  ModCommon
//
//  Created by Kevin Wu on 2022/1/1.
//

import UIKit
import Combine

open class BaseTableViewCell: UITableViewCell, Combinable {

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
  public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
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

}
