//
//  UITableView_Header.swift
//  ModCommon
//
//  Created by Kevin Wu on 2022/1/1.
//

import UIKit

// in vc setup
// tableView.setTableHeader(headerView, nil)
//
// in vc reload
// headerView.reloadTableHeader?()
//
// in v reload
// reloadTableHeader?()

public protocol TableViewHeader: UIView {
  var reloadTableHeader: VoidCb? { get set }
}

public extension UITableView {
  func setTableHeader<Header: TableViewHeader>(_ header: Header, _ width: Double?) {
    header.reloadTableHeader = { [weak self, weak header] in
      guard let self = self else { return }
      guard let header = header else { return }
      header.fitToSystemSize(width ?? SCREEN_WID)
      self.tableHeaderView = header
    }
  }
}

public extension UIView {
  func fitToSystemSize(_ width: Double) {
    let size = systemLayoutSizeFitting(CGSize(width: width, height: UIView.layoutFittingCompressedSize.height))
    frame = CGRect(x: 0, y: 0, width: width, height: size.height)
  }
}
