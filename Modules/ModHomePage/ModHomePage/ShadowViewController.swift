//
//  ShadowViewController.swift
//  ModHomePage
//
//  Created by Kevin Wu on 2022/1/1.
//

import UIKit
import ModCommon

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
            make.pin_waist(20)
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
            valueLabel.text = value.str.zeroTrimmed()
            UIView.animate(withDuration: 0.2, delay: 0) {
                self.valueLabel.transform = CGAffineTransform(scaleX: 1.4, y: 1.4)
            } completion: { _ in
                self.valueLabel.transform = .identity
            }
        }
        @objc func valueChanged() {
            loadValueText()
        }
        @objc func minusAction() {
            value = max(Double(valueSlider.minimumValue), value - step)
            valueSlider.sendActions(for: .valueChanged)
        }
        @objc func plusAction() {
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
            ret.addTarget(self, action: #selector(minusAction), for: .touchUpInside)
            return ret
        }()
        lazy var plusBtn: UIButton = {
            let ret = UIButton(type: .system)
            ret.setTitle("+", for: .normal)
            ret.addTarget(self, action: #selector(plusAction), for: .touchUpInside)
            return ret
        }()
    }
}
