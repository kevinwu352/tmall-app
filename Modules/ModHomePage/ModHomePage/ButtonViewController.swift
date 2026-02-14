//
//  ButtonViewController.swift
//  ModHomePage
//
//  Created by Kevin Wu on 2024/05/17.
//

import UIKit
import ModCommon

class ButtonViewController: BaseViewController {

  override func setup() {
    super.setup()
    img1 = R.image.com.btn_primary_n.cur
    img2 = img1?.brighted(0.05)

    iv1.image = img1
    iv2.image = img2


    view.addSubview(stack1)
    view.addSubview(stack2)
    view.addSubview(stack3)

    view.addSubviews([iv1, iv2])
    view.addSubview(btn1)
    view.addSubview(btn2)


    // btn.tintColor 影响的地方还挺多
    //   plain 文字图标都是红色，当然图标肯定是 template 的
    //   tinted 文字图标都是红色，背景是半透明的红
    //   gray 不受任何影响
    //   filled 文字图标白色，背景是纯红
    //
    // baseForegroundColor 影响所有的文字颜色，如果图片是 template 也受其影响（.glass 的图片不受影响）
    //   连 gray 的文字图标也变色了
    // tintColor 和 baseForegroundColor 同时设置时，前景色优先级更高
    //   连 gray 的文字图标也变色了
    //
    // baseBackgroundColor 影响背景色
    //   plain 本来就没背景色，所以不受影响
    //   其它三个背景色都变了，包括 gray
    // tintColor 和 baseBackgroundColor 同时设置时，背景色优先级更高

    // 可以这样理解：
    //   tintColor 是整体影响，前景后景都影响
    //   baseForegroundColor/baseBackgroundColor 是分另控制前景后景，优先级高于 tintColor


    let handler: (inout UIButton.Configuration?)->Void = {
//      $0?.baseForegroundColor = .green
      $0?.baseBackgroundColor = .green
      $0?.image = UIImage(resource: .Com.iconCross).withRenderingMode(.alwaysTemplate)
    }
    let tintColor: UIColor? = .red


    let confs: [String:UIButton.Configuration] = [
      "plain": .plain(), "tinted": .tinted(), "gray": .gray(), "filled": .filled(),
      "borderless": .borderless(), "borderedTinted": .borderedTinted(), "bordered": .bordered(), "borderedProminent": .borderedProminent(),
    ]
    if true {
      let views = ["plain", "tinted", "gray", "filled"]
        .map { it -> UIButton in
          var conf = confs[it]
          conf?.title = it
          handler(&conf)
          let ret = UIButton(configuration: conf!)
          if let tintColor {
            ret.tintColor = tintColor
          }
          return ret
        }
      stack1.addArrangedSubviews(views)
    }
    if true {
      let views = ["borderless", "borderedTinted", "bordered", "borderedProminent"]
        .map { it -> UIButton in
          var conf = confs[it]
          conf?.title = it
          handler(&conf)
          let ret = UIButton(configuration: conf!)
          if let tintColor {
            ret.tintColor = tintColor
          }
          return ret
        }
      stack2.addArrangedSubviews(views)
    }

    if #available(iOS 26.0, *) {
      let confs: [String:UIButton.Configuration] = [
        "G": .glass(), "PG": .prominentGlass(), "CG": .clearGlass(), "PCG": .prominentClearGlass(),
      ]
      if true {
        let views = ["G", "PG", "CG", "PCG"]
          .map { it -> UIButton in
            var conf = confs[it]
            conf?.title = it
            handler(&conf)
            let ret = UIButton(configuration: conf!)
            if let tintColor {
              ret.tintColor = tintColor
            }
            return ret
          }
        stack3.addArrangedSubviews(views)
      }
    }

//

  }
  override func layoutViews() {
    super.layoutViews()
    stack1.snp.remakeConstraints { make in
      make.leading.equalToSuperview().offset(20)
      make.pin_top(navbar, 20)
    }
    stack2.snp.remakeConstraints { make in
      make.pin_leading(stack1, 20)
      make.top.equalTo(stack1)
    }
    stack3.snp.remakeConstraints { make in
      make.pin_top(stack1, 10)
      make.leading.trailing.equalToSuperview()
    }

    iv1.snp.remakeConstraints { make in
      make.trailing.equalTo(view.snp.centerX).offset(-10)
      make.bottom.equalTo(view.snp.centerY).offset(20)
    }
    iv2.snp.remakeConstraints { make in
      make.leading.equalTo(view.snp.centerX).offset(10)
      make.bottom.equalTo(view.snp.centerY).offset(20)
    }

    btn1.snp.remakeConstraints { make in
      make.centerX.equalToSuperview()
      make.top.equalTo(view.snp.centerY).offset(40)
      make.width.equalTo(200)
    }
    btn2.snp.remakeConstraints { make in
      make.pin_top(btn1, 20)
      make.centerX.equalToSuperview()
    }
  }

  lazy var iv1: UIImageView = {
    let ret = UIImageView()
    ret.layer.borderWidth = 2
    ret.layer.borderColor = UIColor.red.cgColor
    return ret
  }()
  lazy var iv2: UIImageView = {
    let ret = UIImageView()
    ret.layer.borderWidth = 2
    ret.layer.borderColor = UIColor.red.cgColor
    return ret
  }()

  var img1: UIImage?
  var img2: UIImage?

  lazy var btn1: UIButton = {
    let ret = Btn(configuration: .plain())

//    let bgimg_h: ()->UIImage? = {
//      R.image.com.btn_primary_n.cur?.resizableImage(withCapInsets: .init(top: 0, left: 25, bottom: 0, right: 25), resizingMode: .stretch)
//    }
    let img1 = R.image.com.btn_primary_n.cur //?.resizableImage(withCapInsets: .init(top: 0, left: 25, bottom: 0, right: 25), resizingMode: .stretch)
    let img2 = R.image.com.btn_primary_h.cur //?.resizableImage(withCapInsets: .init(top: 0, left: 25, bottom: 0, right: 25), resizingMode: .stretch)


//    ret.style(image: nil, title: .init("abc", .h1, .red))
    ret.style(image: .init((Res.img.alien.cur, nil)),
              title: .init({ _ in "abc" }, { _ in UIFont.boldSystemFont(ofSize: 24) }, { _ in .tintColor }).high(),
              background: .init({
      let ret: UIColor
      switch $0 {
      case .normal: ret = UIColor.red
      case .highlighted: ret = UIColor.green
      case .disabled: ret = UIColor.darkGray
      }
      print("\($0) \(ret)")
      return ret
    })
    )
//    ret.isEnabled = false

//    let bgimg_h: (UIButton.Status)->UIImage? = { [weak self] in
//      ($0.high ? self?.img2 : self?.img1)?
//        .resizableImage(withCapInsets: .init(top: 0, left: 25, bottom: 0, right: 25),
//                        resizingMode: .stretch)
//    }
//    ret.style(image: nil,
//              title: .init("abc", .h1, .white),
//              background: .init({_ in nil }, bgimg_h)
//    )

    return ret
  }()

  lazy var btn2: UIButton = {
//    var config = UIButton.Configuration.plain()
//
//    config.attributedTitle = AttributedString("abc",
//                                              attributes: .fromFont(UIFont.systemFont(ofSize: 14), nil))
//    config.titleTextAttributesTransformer = .init {
//      print("[btn] in transformer")
//      var ret = $0
//      ret.font = UIFont.systemFont(ofSize: btn.isHighlighted ? 15 : 14)
//      return ret
//    }
//
//    let ret = Btn(configuration: config)


    let ret = Btn(configuration: .plain())
    ret.configurationUpdateHandler = { btn in
      print("[btn] in handler")
      let state = btn.state
      var config = btn.configuration ?? .plain()

      let ff = UIColor.white
      let bb = UIColor.tintColor


      config.image = R.image.com.icon_cross.cur?.template
      config.imageColorTransformer = .init {
        print("[btn] in color transformer")
        return $0.withAlphaComponent(state == .highlighted ? 0.75 : 1)
      }

      config.baseForegroundColor = ff
      config.attributedTitle = "abc".attributed(
        UIFont.boldSystemFont(ofSize: 24),
        ff.withAlphaComponent(state == .highlighted ? 0.75 : 1)
      )

//      config.baseBackgroundColor = .purple

      let img = state == .highlighted ? R.image.com.btn_primary_h.cur : R.image.com.btn_primary_n.cur

      config.background.image = img?
        .resizableImage(withCapInsets: .init(top: 0, left: 25, bottom: 0, right: 25),
                        resizingMode: .stretch)

//      config.background.backgroundColor = .purple
      config.background.backgroundColorTransformer = .init {
        print("[btn] in bg transformer")
        return $0.withAlphaComponent(state == .highlighted ? 0.75 : 1)
      }
//      config.background.cornerRadius = 0
//      config.background.strokeWidth = 2
//      config.background.strokeColor = UIColor.red

      btn.configuration = config
    }
    return ret
  }()

  lazy var stack1: UIStackView = {
    let ret = UIStackView()
    ret.axis = .vertical
    ret.alignment = .center
    ret.distribution = .equalSpacing
    ret.spacing = 10
    return ret
  }()
  lazy var stack2: UIStackView = {
    let ret = UIStackView()
    ret.axis = .vertical
    ret.alignment = .center
    ret.distribution = .equalSpacing
    ret.spacing = 10
    return ret
  }()
  lazy var stack3: UIStackView = {
    let ret = UIStackView()
    ret.axis = .horizontal
    ret.alignment = .center
    ret.distribution = .equalSpacing
    ret.spacing = 10
    return ret
  }()

}

class Btn: UIButton {
//  override var isHighlighted: Bool {
//    didSet {
//      print("did set")
//      DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
//        if let color = self.titleLabel?.textColor {
//          print("color: \(color.hexstr) \(color)")
//        }
//        if let bg = self.subviews.first(where: { !($0 is UILabel) }) {
//          if let v = bg.subviews.first {
//            if let color = v.backgroundColor {
//              print("bgxxx: \(color.hexstr) \(color)")
//            }
//          }
//        }
//      }
//    }
//  }
  override var isSelected: Bool {
    get { super.isSelected }
    set {
      super.isSelected = newValue
      print("sel: \(newValue)")
    }
  }
  override var isHighlighted: Bool {
    get { super.isHighlighted }
    set {
      super.isHighlighted = newValue
      print("high: \(newValue)")
    }
  }
  deinit {
    print("btn deinit")
  }
}

//extension UIColor {
//  var hexstr: String {
//    let components = cgColor.components
//    if components?.count == 2 {
//      let r: CGFloat = components?[0] ?? 0.0
//      let a: CGFloat = components?[1] ?? 0.0
//
//      let str = String(format: "#%02lX %f", lroundf(Float(r * 255)), a)
//      return str
//    } else {
//      let r: CGFloat = components?[0] ?? 0.0
//      let g: CGFloat = components?[1] ?? 0.0
//      let b: CGFloat = components?[2] ?? 0.0
//      let a: CGFloat = components?[3] ?? 0.0
//
//      let str = String(format: "#%02lX%02lX%02lX %f", lroundf(Float(r * 255)), lroundf(Float(g * 255)), lroundf(Float(b * 255)), a)
//      return str
//    }
//  }
//}
