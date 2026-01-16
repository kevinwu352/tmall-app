//
//  LabelViewController.swift
//  ModHomePage
//
//  Created by Kevin Wu on 1/23/26.
//

import UIKit
import SnapKit
import ModCommon

class LabelViewController: BaseViewController {

  override func setup() {
    super.setup()
    navbar?.titleLabel.text = "Label"

    view.addSubviews([lb1, lb2, lb3, lb4])
  }
  override func layoutViews() {
    super.layoutViews()

    lb1.snp.remakeConstraints { make in
      make.top.equalToSuperview().offset(200)
      make.centerX.equalToSuperview()
    }
    lb2.snp.remakeConstraints { make in
      make.top.equalTo(lb1.snp.bottom).offset(10)
      make.centerX.equalToSuperview()
    }
    lb3.snp.remakeConstraints { make in
      make.top.equalTo(lb2.snp.bottom).offset(10)
      make.centerX.equalToSuperview()
    }
    lb4.snp.remakeConstraints { make in
      make.top.equalTo(lb3.snp.bottom).offset(10)
      make.leading.trailing.equalToSuperview()
    }
  }
  override func bindEvents() {
    super.bindEvents()
  }


  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesEnded(touches, with: event)
    //    navigationController?.pushViewController(AppleViewController(), animated: true)


    lb1.text = ""

    lb2.fnt = { .boldSystemFont(ofSize: 14) }
    lb2.clr = { .green }
    lb2.alignment = .right
    lb2.breakMode = .byCharWrapping
    lb2.lineHeight = 20
    lb2.lineSpacing = 20
    lb2.paragraphSpacing = (10, 10)
    lb2.config = {
      $0[.underlineStyle] = NSUnderlineStyle.thick.rawValue
      $0[.underlineColor] = UIColor.red
    }
    lb2.text = "aa bb cc"

    lb3.text = "aa <b>bb</b> cc <p>dd</p> ee"

    lb4.text = """
      It is called <a href="http://www.atributika.com">Atributika</a>. @all I
      found #swift #nsattributedstring really nice framework to manage attributed strings.
      Call me if you want to <b>know</b> <p>more</p> (123)456-7890 https://github.com/psharanda/Atributika
      """
    lb4.onLinkTouchUpInside = { _, val in
      //let link = val as? String
    }

  }

  public lazy var lb1: UILabel = {
    let ret = UILabel()
    ret.font = .systemFont(ofSize: 14)
    ret.textColor = .red
    ret.textAlignment = .left
    ret.lineBreakMode = .byWordWrapping
    ret.numberOfLines = 0
    return ret
  }()

  // same style for entire string
  public lazy var lb2: StyLabel = {
    let ret = StyLabel()
    ret.setTextStyles(font: .systemFont(ofSize: 14),
                      color: .red,
                      alignment: .left,
                      breakMode: .byWordWrapping,
                      lineHeight: 20
    ) {
      // 字体横向拉伸，正拉负压，Double
      $0[.expansion] = 1.0
      // 字体倾斜度，正右负左，Double
      $0[.obliqueness] = 1.0
      // 字符间距，间距在后，正扩负缩，Double
      $0[.kern] = 5.0

      $0[.underlineStyle] = NSUnderlineStyle.thick.rawValue
      $0[.underlineColor] = UIColor.red

      $0[.strikethroughStyle] = NSUnderlineStyle.thick.rawValue
      $0[.strikethroughColor] = UIColor.red
    }
    ret.chg.theme("update") { $0.reload(nil) }
    ret.numberOfLines = 0
    return ret
  }()

  // different style for each markup
  public lazy var lb3: StyLabel = {
    let ret = StyLabel()
    ret.setMarkStyles(
      tags: [
        "b": .init().font(.boldSystemFont(ofSize: 14)),
        "p": .init().foregroundColor(.purple)
      ],
      base: .init()
        .font(.systemFont(ofSize: 14))
        .foregroundColor(.darkGray)
        .paragraphStyle(.fromBase(base: nil, alignment: .left, breakMode: .byWordWrapping, lineHeight: 20))
    )
    ret.chg.theme("update") { $0.reload(nil) }
    ret.numberOfLines = 0
    return ret
  }()

  // with link/mention/hashtag
  public lazy var lb4: AttLabel = {
    let ret = AttLabel()
    //ret.linkDetectionEnabled = false
    ret.setMarkStyles(
      tags: [
        "a": .init().foregroundColor(.red),
        "@": .init().foregroundColor(.green),
        "#": .init().foregroundColor(.blue),
        "b": .init().font(.boldSystemFont(ofSize: 14)),
        "p": .init().foregroundColor(.purple),
      ],
      high: .init().foregroundColor(.green),
      base: .init()
        .font(.systemFont(ofSize: 14))
        .foregroundColor(.darkGray)
        .paragraphStyle(.fromBase(base: nil, alignment: .left, breakMode: .byWordWrapping, lineHeight: 20))
    )
    ret.chg.theme("update") { $0.reload(nil) }
    ret.numberOfLines = 0
    return ret
  }()

}
