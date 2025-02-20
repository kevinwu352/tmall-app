//
//  FontViewController.swift
//  ModHomePage
//
//  Created by Kevin Wu on 2024/07/19.
//

import UIKit
import ModCommon

class FontViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {

  override func setup() {
    super.setup()
    view.addSubview(searchField)
    view.addSubview(infoLabel)
    view.addSubview(tableView)

    setupTap(nil)
    tapRec.cancelsTouchesInView = false

    navbar?.trailingStack.removeAllArrangedSubviews()
    navbar?.trailingStack.addArrangedSubview(steperView)
    navbar?.trailingStack.alignment = .center

    search()
    reloadInfo()
  }
  override func layoutViews() {
    super.layoutViews()
    searchField.snp.remakeConstraints { make in
      make.pin_top(navbar, 5)
      make.leading.trailing.equalToSuperview().inset(5)
    }
    infoLabel.snp.remakeConstraints { make in
      make.pin_top(searchField, 5)
      make.leading.trailing.equalToSuperview().inset(5)
    }
    tableView.snp.remakeConstraints { make in
      make.leading.trailing.bottom.equalToSuperview()
      make.pin_top(infoLabel, 5)
    }
  }
  override func bindEvents() {
    super.bindEvents()
    searchField.cmb.text
      .sink { [weak self] _ in
        self?.search()
        self?.reloadInfo()
      }
      .store(in: &cancellables)
  }

  struct Group {
    var family: String
    var names: [String]
    var open = true
  }
  lazy var raw: [Group] = UIFont.familyNames.map { Group(family: $0, names: UIFont.fontNames(forFamilyName: $0)) }
  lazy var groups: [Group] = []


  func search() {
    if let text = searchField.text?.lowercased(), text.notEmpty {
      groups = raw.filter { $0.family.lowercased().contains(text) }
    } else {
      groups = raw
    }
    tableView.reloadData()
  }

  func reloadInfo() {
    let total = raw.reduce(0) { $0 + $1.names.count }
    let search_total = groups.reduce(0) { $0 + $1.names.count }

    infoLabel.text = "family:\(raw.count)(\(groups.count)), total:\(total)(\(search_total))"
  }

  override func tapped(_ sender: UIGestureRecognizer) {
    searchField.resignFirstResponder()
  }

  lazy var steperView: SteperView = {
    let ret = SteperView()
    ret.valueAct = { [weak self] in self?.tableView.reloadData() }
    return ret
  }()

  lazy var infoLabel: UILabel = {
    let ret = UILabel()
    ret.font = .systemFont(ofSize: 14)
    ret.textColor = .black
    ret.textAlignment = .left
    ret.lineBreakMode = .byWordWrapping
    ret.numberOfLines = 0
    return ret
  }()

  lazy var searchField: UITextField = {
    let ret = UITextField()
    ret.borderStyle = .line
    ret.autocapitalizationType = .none
    ret.autocorrectionType = .no
    ret.spellCheckingType = .no
    ret.clearButtonMode = .always
    return ret
  }()

  lazy var tableView: UITableView = {
    let ret = UITableView(frame: .zero, style: .plain)
    ret.register(EntryCell.self, forCellReuseIdentifier: "cell")
    ret.rowHeight = 60
    ret.dataSource = self
    ret.delegate = self
    ret.sectionHeaderTopPadding = 0
    return ret
  }()

  func numberOfSections(in tableView: UITableView) -> Int {
    groups.count
  }
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    groups[section].open ? groups[section].names.count : 0
  }
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! EntryCell
    let name = groups[indexPath.section].names[indexPath.row]
    cell.font = UIFont(name: name, size: steperView.steper.value)
    cell.infoLabel.text = name
    return cell
  }

  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    30
  }
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let hv = HeadView()
    hv.tag = section
    hv.label.text = groups[section].family
    hv.tapAction = { [weak self] in
      self?.groups[section].open.toggle()
      self?.tableView.reloadData()
    }
    return hv
  }

  class SteperView: BaseView {
    override func setup() {
      super.setup()
      addSubview(steper)
      addSubview(label)
    }
    override func layoutViews() {
      super.layoutViews()
      steper.snp.remakeConstraints { make in
        make.edges.equalToSuperview()
      }
      label.snp.remakeConstraints { make in
        make.center.equalToSuperview()
      }
    }
    @objc func valueClicked() {
      label.text = steper.value.s.zeroTrimmed()
      valueAct?()
    }
    var valueAct: (()->Void)?
    lazy var steper: UIStepper = {
      let ret = UIStepper()
      ret.minimumValue = 8
      ret.maximumValue = 32
      ret.stepValue = 1
      ret.value = 14
      ret.addTarget(self, action: #selector(valueClicked), for: .valueChanged)
      return ret
    }()
    lazy var label: UILabel = {
      let ret = UILabel()
      ret.font = .systemFont(ofSize: 14)
      ret.textColor = .black
      ret.textAlignment = .center
      ret.text = "14"
      return ret
    }()
  }

  class HeadView: BaseView {
    override func setup() {
      super.setup()
      backgroundColor = .lightGray
      addSubview(label)
      addSubview(line)
      setupTap(nil)
    }
    override func layoutViews() {
      super.layoutViews()
      label.snp.remakeConstraints { make in
        make.leading.equalToSuperview().offset(10)
        make.centerY.equalToSuperview()
      }
      line.snp.remakeConstraints { make in
        make.leading.trailing.bottom.equalToSuperview()
        make.height.equalTo(0.5)
      }
    }
    var tapAction: (()->Void)?
    override func tapped(_ sender: UIGestureRecognizer) {
      tapAction?()
    }
    lazy var label: UILabel = {
      let ret = UILabel()
      ret.font = .systemFont(ofSize: 14)
      ret.textColor = .black
      return ret
    }()
    lazy var line: UIView = {
      let ret = UIView()
      ret.backgroundColor = .darkGray
      return ret
    }()
  }

  class EntryCell: BaseTableViewCell {
    override func setup() {
      super.setup()
      contentView.addSubview(infoLabel)
      contentView.addSubview(trailLabel)
    }
    override func layoutViews() {
      super.layoutViews()
      infoLabel.snp.remakeConstraints { make in
        make.leading.equalToSuperview().offset(10)
        make.centerY.equalToSuperview()
      }
      trailLabel.snp.remakeConstraints { make in
        make.trailing.equalToSuperview().offset(-10)
        make.centerY.equalToSuperview()
      }
    }
    var font: UIFont? {
      didSet {
        infoLabel.font = font
        masy(0.25) { [weak self] in
          guard let self = self else { return }
          self.trailLabel.text = Num(self.infoLabel.frame.height).scaleDown(2)
        }
      }
    }
    lazy var infoLabel: UILabel = {
      let ret = UILabel()
      ret.font = .systemFont(ofSize: 14)
      ret.textColor = .red
      return ret
    }()
    lazy var trailLabel: UILabel = {
      let ret = UILabel()
      ret.font = .systemFont(ofSize: 14)
      ret.textColor = .blue
      return ret
    }()
  }

}
