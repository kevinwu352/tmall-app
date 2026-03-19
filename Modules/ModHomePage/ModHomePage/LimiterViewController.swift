//
//  LimiterViewController.swift
//  ModHomePage
//
//  Created by Kevin Wu on 3/19/26.
//

import Combine
import ModCommon
import UIKit

class LimiterViewController: UIViewController {

  lazy var bag = Set<AnyCancellable>()

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white

    view.addSubview(textField)
    textField.snp.remakeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(20)
      make.top.equalToSuperview().offset(100)
      make.height.equalTo(40)
    }

    textField.cmb.text
      .sink { str in
        print("[tf] got:\(str ?? "")")
      }
      .store(in: &bag)
  }

  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesEnded(touches, with: event)
    // textField.resignFirstResponder()
    // textField.txt
    //   .sink { str in
    //     print("[tf] got:\(str ?? "")")
    //   }
    //   .store(in: &bag)
  }

  lazy var textField: UITextField = {
    let ret = UITextField()
    ret.backgroundColor = .lightGray
    ret.textColor = .red
    ret.autocapitalizationType = .none
    ret.autocorrectionType = .no
    ret.spellCheckingType = .no
    // ret.limiter = TextLimiter(maxLength: 10, allowedCharset: CharacterSet(charactersIn: "12345"))
    // ret.limiter = IntLimiter(maxLength: 5, negativable: false, min: nil, max: "25")
    ret.addTarget(self, action: #selector(textChanged), for: .editingChanged)
    ret.addTarget(self, action: #selector(textChanged), for: .editingDidEnd)
    ret.addTarget(self, action: #selector(textChanged), for: .editingDidEndOnExit)
    return ret
  }()

  // 所以，
  // delegate 是输入前决定能不能修改
  // event 是输入后，对输入进行修正，适用的情况不一样
  //
  // 我感觉，少用事前的，多用事后的，让用户自由输入
  // 只是当用户输入的值不当时，把边框变成红色来提示用户，而不是让用户按了键盘没反应
  //
  // 总共四个限制：
  // 长度，事前事后都可以，如果简单需求，用事前也行，用 TextLimiter
  // 字符，事前事后都可以，如果简单需求，用事前也行，用 TextLimiter
  // 正则，事前判断其实有点麻烦，0. 这种中间形态也要允许，事后判断的话只需要判断最终形态，如果输入 . 可以修正为 0.
  // 最小最大，事后判断好一点，如果超过最小最大，可以修正为最小最大值

  // 不管 publisher 是订阅的先后，总是先触发这里，再触发 publisher，为何？
  @objc func textChanged(_ sender: UITextField) {
    print("[tf] Changed:\(sender.text ?? "")")
    let text = sender.text ?? ""
    if let value = Int(text), value > 20 {
      sender.text = "20" // 赋 21 会造成循环

      // 不主动发送编辑事件时
      // [tf] Changed:123
      // [tf] got:20

      // 主动发送编辑事件时，并未造成循环触发，因为 if 没触发
      // 而且，并不是前一个事件处理完再处理新事件，而是这里处理两次，publisher 再处理两次
      // [tf] Changed:123
      // [tf] Changed:20
      // [tf] got:20
      // [tf] got:20
      sender.sendActions(for: .editingChanged)

      // 延迟发送编辑事件时
      // [tf] Changed:123
      // [tf] got:20
      // [tf] send event
      // [tf] Changed:20
      // [tf] got:20
      // DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
      //   print("[tf] send event")
      //   sender.sendActions(for: .editingChanged)
      // }

      // 事实证明，发送一次编辑事件，回调就会响应一次，不管文字是否真的变化，所以，
      // 1) publisher 那边，最好是去重
      // 2) 而这边的话，给 textField 赋新的值，并发送编辑事件，这会触发 publisher 和 此回调，新的值千万不能再触发 if，否则会循环
    }
  }
  @objc func textDidEnd(_ sender: UITextField) {
    print("[tf] DidEnd:\(sender.text ?? "")")
  }
  @objc func textDidEndOnExit(_ sender: UITextField) {
    print("[tf] DidEndOnExit:\(sender.text ?? "")")
  }

}
