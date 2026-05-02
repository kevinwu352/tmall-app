//
//  GestureViewController.swift
//  ModHomePage
//
//  Created by Kevin Wu on 3/28/26.
//

import UIKit
import ModCommon

// delaysTouchesBegan = false
//   为真 且 手势识别成功，则不发后续事件        <= 重点注意
//   为真 且 手势识别失败，点击正常响应
//   为假 且 手势识别失败，点击正常响应。因为假不会阻断点击，只是此时手势识别失败了，手势没响应
//   为假 且 手势识别成功，根据下面的 cancel 来决定是 cancel/end

// cancelsTouchesInView = true
//   为真 且 手势识别成功，则不发后续事件，如果已发过事件，则发 cancel 事件
//   为假 或 手势识别失败，发送所有事件

// delaysTouchesEnded = true
// 为真 且 手势识别成功，则发送 cancelled 事件
// 为真 且 手势识别失败，则发送 ended 事件


// 延迟开始 要取消 延迟结束，识别成功
//   tapped
// 延迟开始 不取消 延迟结束，识别成功
//   tapped
// 正常开始 要取消 延迟结束，识别成功
//   touch began
//   tapped
//   touch cancelled
// 正常开始 不取消 延迟结束，识别成功
//   touch began
//   tapped
//   touch ended
//
// 延迟开始 要取消 延迟结束，识别失败
//   touch began
//   touch ended
// 延迟开始 不取消 延迟结束，识别失败
//   touch began
//   touch ended
// 正常开始 要取消 延迟结束，识别失败
//   touch began
//   touch ended
// 正常开始 不取消 延迟结束，识别失败
//   touch began
//   touch ended
//
// 正常结束时，效果同上

// 总结下来：
//   延迟开始时，手势和点击是互斥的
//   正常开始时
//     手势识别失败，点击正常触发，只是手势没触发而已
//     手势识别成功，点击正常触发，只是根据 cancel 的值来决定发送 cancel/end 事件
//
// 延迟开始，识别成功
//   tapped
// 延迟开始，识别失败
//   touch began
//   touch ended
//
// 正常开始，识别失败
//   touch began
//   touch ended
// 正常开始 要取消，识别成功
//   touch began
//   tapped
//   touch cancelled
// 正常开始 不取消，识别成功
//   touch began
//   tapped
//   touch ended

class GestureViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

  override func viewDidLoad() {
    super.viewDidLoad()

    // view.addGestureRecognizer(gesture)

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

    view.addSubview(textField)
    textField.snp.remakeConstraints { make in
      make.leading.equalToSuperview()
      make.top.equalToSuperview().offset(100)
      make.size.equalTo(CGSize(width: 200, height: 40))
    }

    view.addSubview(showBtn)
    showBtn.snp.remakeConstraints { make in
      make.bottom.equalToSuperview().offset(-34)
      make.centerX.equalToSuperview()
    }

  }

  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesBegan(touches, with: event)
    print("touch began")
    // textField.resignFirstResponder()
  }
  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesMoved(touches, with: event)
    print("touch moved")
  }
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesEnded(touches, with: event)
    print("touch ended")
  }
  override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesCancelled(touches, with: event)
    print("touch cancelled")
  }

  // 用的时候请多次尝试修改下面三个属性的值
  // 再分别点击 按钮/cell/table-view/view，看看它们的触发规律，要试试 短按/长按
  // 长按的目的是让 tap 识别失败，因为 gesture 能取消 touch 事件，所以试试能否正常响应
  //
  // delay:true cancel:true 时，按钮和输入框正常响应，但 view/table/cell 触发手势
  //   注意：理论上，我 tap 应该触发手势，而不是按钮和输入框，可见，这俩货的优先级高
  // delay:true cancel:false 时，点击除输入框之外所有的都触发手势，只有在长按让手势失败后才会触发相应的，很怪
  //   注意：点击输入框不会触发手势，且能弹出键盘，可见这输入框优先级最高
  //
  // delay:false cancel:true 时，按钮和输入框正常响应，但 view/table/cell 触发手势，且 view 会触发 touch-begin 和 touch-cancel
  //   注意：虽然不延迟，但在手势识别成功后，会取消点击，但无法取消按钮的点击
  //   注意：点击输入框不会触发手势，且能弹出键盘，可见这输入框优先级最高
  // delay:false cancel:false 时，点击和手势都能触发
  //   注意：点击输入框不会触发手势，且能弹出键盘，可见这输入框优先级最高
  //
  // table 会吞掉点击事件，它后面的 view 收不到
  //
  // 经过试验，如果要收起键盘，把 gesture 加到 view 上，然后 cancels=false delay=false 效果比较好，最好加 tap/long-press 两个
  lazy var gesture: UIGestureRecognizer = {
    // let ret = UILongPressGestureRecognizer(target: self, action: #selector(tapped))
    // ret.minimumPressDuration = 5.0
    let ret = UITapGestureRecognizer(target: self, action: #selector(tapped))
    ret.delaysTouchesBegan = false
    ret.cancelsTouchesInView = false
    ret.delaysTouchesEnded = false
    print("delaysTouchesBegan:\(ret.delaysTouchesBegan), cancelsTouchesInView:\(ret.cancelsTouchesInView), delaysTouchesEnded:\(ret.delaysTouchesEnded)")
    return ret
  }()
  @objc func tapped() {
    print("tapped")
    // textField.resignFirstResponder()
  }

  lazy var tableView: UITableView = {
    let ret = UITableView(frame: .zero, style: .plain)
    ret.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    ret.backgroundColor = .brown
    ret.keyboardDismissMode = .onDrag
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

  lazy var textField: UITextField = {
    let ret = UITextField()
    ret.backgroundColor = .lightGray
    return ret
  }()

  lazy var showBtn: UIButton = {
    let ret = UIButton(type: .system)
    ret.setTitle("show", for: .normal)
    ret.addTarget(self, action: #selector(showAlert), for: .touchUpInside)
    ret.backgroundColor = .green
    return ret
  }()
  @objc func showAlert() {
    print("show")
    // 其它都能正常工作，只是，点击键盘的时候不会触发手势，所以，隐藏不了。自己处理吧
    // 如果某个页面没有输入框，那么，这方案是完美的
    let av = TapAlertView()
    view.addSubview(av)
    av.snp.remakeConstraints { make in
      make.center.equalToSuperview()
    }
    view.addGestureRecognizer(av.gesture)
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

class TapAlertView: BaseView {
  override func setup() {
    super.setup()
    backgroundColor = .red
  }
  override var intrinsicContentSize: CGSize {
    CGSize(width: 300, height: 200)
  }
  lazy var gesture: UIGestureRecognizer = {
    let ret = UITapGestureRecognizer(target: self, action: #selector(grtapped))
    ret.delaysTouchesBegan = false
    ret.cancelsTouchesInView = false
    ret.delaysTouchesEnded = false
    return ret
  }()
  @objc func grtapped(_ gest: UIGestureRecognizer) {
    let pt = gest.location(in: self)
    print(gest)
    if bounds.contains(pt) {
      print("click in")
    } else {
      print("click out")
      removeFromSuperview()
      print("before: \(gest.view?.gestureRecognizers)")
      gest.view?.removeGestureRecognizer(gest)
      print("after: \(gest.view?.gestureRecognizers)")
    }

  }
  deinit {
    print("deinit alert")
  }
  // override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
  //   super.touchesBegan(touches, with: event)
  // }
}
