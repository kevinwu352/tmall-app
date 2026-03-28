//
//  GestureViewController.swift
//  ModHomePage
//
//  Created by Kevin Wu on 3/28/26.
//

import UIKit

class GestureViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

  override func viewDidLoad() {
    super.viewDidLoad()

    view.addGestureRecognizer(gesture)

    view.addSubview(tableView)
    tableView.snp.remakeConstraints { make in
      make.leading.trailing.top.equalToSuperview()
      make.height.equalTo(400)
    }

    view.addSubview(floatBtn)
    floatBtn.snp.remakeConstraints { make in
      make.trailing.equalToSuperview()
      make.top.equalToSuperview().offset(100)
      make.size.equalTo(CGSize(width: 100, height: 40))
    }

  }

  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesBegan(touches, with: event)
    print("vc touch began")
  }
  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesMoved(touches, with: event)
    print("vc touch moved")
  }
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesEnded(touches, with: event)
    print("vc touch ended")
  }
  override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesCancelled(touches, with: event)
    print("vc touch cancelled")
  }

  // 用的时候请多次尝试修改下面三个属性的值
  // 再分别点击 按钮/cell/table-view/view，看看它们的触发规律，要试试 短按/长按
  // 长按的目的是让 tap 识别失败，因为 gesture 能取消 touch 事件，所以试试能否正常响应
  //
  // 经过试验，如果要收起键盘，把 gesture 加到 view 上，然后 cancelsTouchesInView = false 效果比较好
  // 最好加 tap/long-press 两个
  lazy var gesture: UIGestureRecognizer = {
    let ret = UITapGestureRecognizer(target: self, action: #selector(tapped))
    ret.cancelsTouchesInView = false
    print(ret.cancelsTouchesInView)
    print(ret.delaysTouchesBegan)
    print(ret.delaysTouchesEnded)
    return ret
  }()
  @objc func tapped() {
    print("tapped")
  }

  lazy var tableView: UITableView = {
    let ret = UITableView(frame: .zero, style: .plain)
    ret.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    ret.backgroundColor = .brown
    ret.dataSource = self
    ret.delegate = self
    return ret
  }()

  lazy var floatBtn: UIButton = {
    let ret = UIButton(type: .system)
    ret.setTitle("run", for: .normal)
    ret.addTarget(self, action: #selector(clicked), for: .touchUpInside)
    ret.backgroundColor = .red
    return ret
  }()
  @objc func clicked() {
    print("clicked")
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    5
  }
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
    cell.textLabel?.text = "index - \(indexPath.row)"
    return cell
  }
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    print("select:\(indexPath.row)")
  }

}
