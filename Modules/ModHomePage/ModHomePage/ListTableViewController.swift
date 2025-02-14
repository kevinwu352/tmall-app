//
//  ListTableViewController.swift
//  ModHomePage
//
//  Created by Kevin Wu on 2022/1/1.
//

import UIKit
import Combine
import ModCommon

class ListTableViewController: BaseViewController {
  override func setup() {
    super.setup()
    view.addSubview(tableView)
  }
  override func layoutViews() {
    super.layoutViews()
    tableView.snp.remakeConstraints { make in
      make.leading.trailing.bottom.equalToSuperview()
      if let navbar = navbar, !navbar.isHidden {
        make.top.equalTo(navbar.snp.bottom)
      } else {
        make.top.equalToSuperview()
      }
    }
  }

  override func bindEvents() {
    super.bindEvents()

    vm.users.$value
      .sink { [weak self] _ in
        self?.tableView.reloadData()
      }
      .store(in: &cancellables)

    vm.users.$loading
      .sink { [weak self] in
        if $0 {
          // ...
        } else {
          self?.tableView.headEndRefreshing()
        }
      }
      .store(in: &cancellables)



    _ = vm.transform(.init(
      head: tableView.headPublisher.eraseToAnyPublisher()
    ))
  }

  lazy var vm = ListViewModel()


  lazy var tableView: UITableView = {
    let ret = UITableView(frame: .zero, style: .plain)
    ret.register(ListCell.self, forCellReuseIdentifier: ListCell.reuseId)
    ret.rowHeight = 100
    ret.dataSource = self
    ret.headReset(true)
    return ret
  }()
}

extension ListTableViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    vm.users.listv.count
  }
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: ListCell.reuseId, for: indexPath) as! ListCell
    cell.valueLabel.text = vm.users.listv[indexPath.row].name
    return cell
  }
}


class ListViewModel: BaseObject {

  var users = Prop<Lst<Person>>()

  struct Input {
    let head: AnyPublisher<Void, Never>
  }

  struct Output {
  }

  func transform(_ input: Input) -> Output {

    input.head
      .fallth { [weak self] in self?.users.begin(.first) }
      .map {
        MainHTTP
          .publish(api: .lst(), object: Lst<Person>.self)
          .eraseToAnyPublisher()
      }
      .switchToLatest()
      .sink { [weak self] in
        self?.users.end($0.object, $0.err)
      }
      .store(in: &cancellables)

    return .init()
  }

}


class ListCell: BaseTableViewCell {
  override func setup() {
    super.setup()
    contentView.addSubview(valueLabel)
  }
  override func layoutViews() {
    super.layoutViews()
    valueLabel.snp.remakeConstraints { make in
      make.center.equalToSuperview()
    }
  }
  lazy var valueLabel: UILabel = {
    let ret = UILabel()
    return ret
  }()
}
