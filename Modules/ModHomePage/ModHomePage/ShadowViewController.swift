//
//  ShadowViewController.swift
//  ModHomePage
//
//  Created by Kevin Wu on 2022/1/1.
//

import UIKit
import ModCommon

// 阴影跟随着视图的边缘，如果视图背景透明，阴影也看不到
// 给视图加一个 UILabel，阴影将会沿着内部文字的边缘
// 给 UILabel 加上背景色，阴影将会沿着 UILabel 的边缘
// 背景色透明的同时，如果视图有边框，那么阴影会沿着边框，呈环状
// 既有边框，也有中间文字，那么阴影会有两部分，一部分沿着边框，一部分沿着文字
// 总结：反正阴影是沿着视图不透明部分的边沿走的
//
// lazy var shadowView: UIView = {
//   let ret = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
//   ret.backgroundColor = .clear // (1)
//   ret.layer.shadowColor = UIColor.red.cgColor
//   ret.layer.shadowOpacity = 1
//   ret.layer.shadowOffset = CGSize(width: 5, height: 5)
//   ret.layer.shadowRadius = 5
//   let lb = UILabel()
//   lb.text = "xxx"
//   lb.backgroundColor = .yellow
//   ret.addSubview(lb)
//   lb.sizeToFit()
//   lb.frame = CGRect(x: (100 - lb.bounds.width)/2, y: (100 - lb.bounds.height)/2, width: lb.bounds.width, height: lb.bounds.height)
//   return ret
// }()

// 如果视图内部，添加 sub layer，在子层上加阴影，必须加 shadowPath 才能看到
// 此时，就算视图背景是透明的，也能看到阴影，且阴影是实心的，而非环状
// 如果要加背景色的话，先加阴影层，再加背景色层
class ShadowView: UIView {
  required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
  override init(frame: CGRect) {
    super.init(frame: frame)
    backgroundColor = .clear
    layer.masksToBounds = false

    // let layer1 = CALayer()
    // layer1.name = "shadow"
    // layer1.shadowColor = UIColor.red.cgColor
    // layer1.shadowOpacity = 1
    // layer1.shadowRadius = 5
    // layer1.shadowOffset = CGSize(width: 0, height: 5)
    // layer.addSublayer(layer1)
    // let layer2 = CALayer()
    // layer2.name = "background"
    // layer2.backgroundColor = UIColor.green.cgColor
    // layer2.cornerRadius = 24
    // layer.addSublayer(layer2)
    let shadowLayer = CAShapeLayer()
    shadowLayer.name = "shadow"
    shadowLayer.fillColor = UIColor.green.cgColor
    shadowLayer.shadowColor = UIColor.red.cgColor
    shadowLayer.shadowOpacity = 1
    shadowLayer.shadowRadius = 5
    shadowLayer.shadowOffset = CGSize(width: 0, height: 5)
    layer.addSublayer(shadowLayer)

    addSubview(lb)
    lb.snp.remakeConstraints { make in
      make.center.equalToSuperview()
    }
  }
  override func layoutSubviews() {
    super.layoutSubviews()
    // layer.sublayers?.first(where: { $0.name == "shadow" })?.frame = bounds
    // layer.sublayers?.first(where: { $0.name == "shadow" })?.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: 24).cgPath
    // layer.sublayers?.first(where: { $0.name == "background" })?.frame = bounds
    if let shadowLayer = layer.sublayers?.first(where: { $0.name == "shadow" }) as? CAShapeLayer {
      shadowLayer.frame = bounds
      shadowLayer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: 24).cgPath
      shadowLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: 24).cgPath
    }
  }
  override var intrinsicContentSize: CGSize {
    CGSize(width: 200, height: 100)
  }
  lazy var lb: UILabel = {
    let ret = UILabel()
    ret.text = "HEHE"
    return ret
  }()
}

class ShadowViewController: BaseViewController {

    override func setup() {
        super.setup()
        view.addSubview(shadowView)
        view.addSubview(stackView)

        stackView.addArrangedSubviews([radiusFv, opacityFv, offsetxFv, offsetyFv])
    }
    override func layoutViews() {
        super.layoutViews()
        shadowView.snp.remakeConstraints { make in
            make.pin_top(navbar, 50)
            make.centerX.equalToSuperview()
            make.size.equalTo(CGSize(width: 100, height: 100))
        }
        stackView.snp.remakeConstraints { make in
            make.pin_top(shadowView, 50)
            make.leading.trailing.equalToSuperview().inset(20)
        }
    }
    override func reload() {
        super.reload()

        shadowView.layer.shadowColor = UIColor.black.cgColor
        shadowView.layer.shadowRadius = radiusFv.value
        shadowView.layer.shadowOpacity = Float(opacityFv.value)
        shadowView.layer.shadowOffset = CGSize(width: offsetxFv.value, height: offsetyFv.value)
    }

    @objc func valueChanged() {
        reload()
    }

    lazy var radiusFv: FieldView = {
        let ret = FieldView()
        ret.titleLabel.text = "radius"
        ret.valueSlider.minimumValue = 0
        ret.valueSlider.maximumValue = 10
        ret.value = 6
        ret.step = 1
        ret.valueSlider.addTarget(self, action: #selector(valueChanged), for: .valueChanged)
        return ret
    }()
    lazy var opacityFv: FieldView = {
        let ret = FieldView()
        ret.titleLabel.text = "opacity"
        ret.valueSlider.minimumValue = 0
        ret.valueSlider.maximumValue = 1
        ret.value = 0.25
        ret.step = 0.05
        ret.valueSlider.addTarget(self, action: #selector(valueChanged), for: .valueChanged)
        return ret
    }()
    lazy var offsetxFv: FieldView = {
        let ret = FieldView()
        ret.titleLabel.text = "offsetx"
        ret.valueSlider.minimumValue = -10
        ret.valueSlider.maximumValue = 10
        ret.value = 0
        ret.step = 1
        ret.valueSlider.addTarget(self, action: #selector(valueChanged), for: .valueChanged)
        return ret
    }()
    lazy var offsetyFv: FieldView = {
        let ret = FieldView()
        ret.titleLabel.text = "offsety"
        ret.valueSlider.minimumValue = -10
        ret.valueSlider.maximumValue = 10
        ret.value = 0
        ret.step = 1
        ret.valueSlider.addTarget(self, action: #selector(valueChanged), for: .valueChanged)
        return ret
    }()
    

    lazy var shadowView: UIView = {
        let ret = UIView()
        ret.backgroundColor = .yellow
        ret.layer.cornerRadius = 10
        return ret
    }()

    lazy var stackView: UIStackView = {
        let ret = UIStackView()
        ret.axis = .vertical
        ret.alignment = .fill
        ret.distribution = .equalSpacing
        ret.spacing = 5
        return ret
    }()

    class FieldView: BaseView {
        override func setup() {
            super.setup()
            backgroundColor = UIColor.black.withAlphaComponent(0.05)
            addSubview(titleLabel)
            addSubview(valueLabel)
            addSubview(valueSlider)
            addSubview(minusBtn)
            addSubview(plusBtn)
        }
        override func layoutViews() {
            super.layoutViews()
            titleLabel.snp.remakeConstraints { make in
                make.leading.top.equalToSuperview()
                make.trailing.equalTo(snp.centerX)
            }
            valueLabel.snp.remakeConstraints { make in
                make.pin_leading(titleLabel, 5)
                make.centerY.equalTo(titleLabel)
            }
            minusBtn.snp.remakeConstraints { make in
                make.leading.bottom.equalToSuperview()
                make.pin_top(titleLabel, 0)
            }
            plusBtn.snp.remakeConstraints { make in
                make.trailing.bottom.equalToSuperview()
            }
            valueSlider.snp.remakeConstraints { make in
                make.pin_leading(minusBtn, 0)
                make.pin_trailing(plusBtn, 0)
                make.centerY.equalTo(minusBtn)
            }
        }
        var value: Double {
            get { Double(valueSlider.value) }
            set {
                valueSlider.value = Float(newValue)
                loadValueText()
            }
        }
        var step: Double = 0.0
        func loadValueText() {
            valueLabel.text = value.s.zeroTrimmed()
            UIView.animate(withDuration: 0.2, delay: 0) {
                self.valueLabel.transform = CGAffineTransform(scaleX: 1.4, y: 1.4)
            } completion: { _ in
                self.valueLabel.transform = .identity
            }
        }
        @objc func valueChanged() {
            loadValueText()
        }
        @objc func minusClicked() {
            value = max(Double(valueSlider.minimumValue), value - step)
            valueSlider.sendActions(for: .valueChanged)
        }
        @objc func plusClicked() {
            value = min(Double(valueSlider.maximumValue), value + step)
            valueSlider.sendActions(for: .valueChanged)
        }
      lazy var titleLabel: UILabel = {
        let ret = UILabel()
        ret.font = .systemFont(ofSize: 14)
        ret.textColor = .darkGray
        ret.textAlignment = .right
        ret.lineBreakMode = .byWordWrapping
        return ret
      }()
        lazy var valueLabel: UILabel = {
          let ret = UILabel()
          ret.font = .systemFont(ofSize: 14)
          ret.textColor = .black
          ret.textAlignment = .left
          ret.lineBreakMode = .byWordWrapping
            return ret
        }()
        lazy var valueSlider: UISlider = {
            let ret = UISlider()
            ret.addTarget(self, action: #selector(valueChanged), for: .valueChanged)
            return ret
        }()
        lazy var minusBtn: UIButton = {
            let ret = UIButton(type: .system)
            ret.setTitle("-", for: .normal)
            ret.addTarget(self, action: #selector(minusClicked), for: .touchUpInside)
            return ret
        }()
        lazy var plusBtn: UIButton = {
            let ret = UIButton(type: .system)
            ret.setTitle("+", for: .normal)
            ret.addTarget(self, action: #selector(plusClicked), for: .touchUpInside)
            return ret
        }()
    }
}
