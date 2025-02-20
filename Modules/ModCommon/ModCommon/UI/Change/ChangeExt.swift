//
//  ChangeExt.swift
//  ModCommon
//
//  Created by Kevin Wu on 2022/1/1.
//

import UIKit

public extension Collection {
  var thm: Element? { at(THEME.rawValue) }
  var lan: Element? { at(LANGUAGE.rawValue) }
}


public extension Change where Base: UIView {
  func backgroundColor(_ h: @escaping @autoclosure ()->UIColor?) {
    theme(#function) { $0.backgroundColor = h() }
  }
  func tintColor(_ h: @escaping @autoclosure ()->UIColor?) {
    theme(#function) { $0.tintColor = h() }
  }
}

public extension Change where Base: CALayer {
  func backgroundColor(_ h: @escaping @autoclosure ()->CGColor?) {
    theme(#function) { $0.backgroundColor = h() }
  }
}

public extension Change where Base: UILabel {
  func text(_ h: @escaping @autoclosure ()->String?) {
    language(#function) { $0.text = h() }
  }
  func textColor(_ h: @escaping @autoclosure ()->UIColor?) {
    theme(#function) { $0.textColor = h() }
  }
  func attributedText(_ h: @escaping @autoclosure ()->NSAttributedString?) {
    both(#function) { $0.attributedText = h() }
  }
}

public extension Change where Base: UIImageView {
  func image(_ h: @escaping @autoclosure ()->UIImage?) {
    theme(#function) { $0.image = h() }
  }
}


// =============================================================================

public extension Change where Base: UIButton {
  func setTitle(_ h: @escaping @autoclosure ()->String?, _ state: UIControl.State) {
    language(#function) { $0.setTitle(h(), for: state) }
  }
  func setTitleColor(_ h: @escaping @autoclosure ()->UIColor?, _ state: UIControl.State) {
    theme(#function) { $0.setTitleColor(h(), for: state) }
  }
  func setImage(_ h: @escaping @autoclosure ()->UIImage?, _ state: UIControl.State) {
    theme(#function) { $0.setImage(h(), for: state) }
  }
  func setBackgroundImage(_ h: @escaping @autoclosure ()->UIImage?, _ state: UIControl.State) {
    theme(#function) { $0.setBackgroundImage(h(), for: state) }
  }
}

public extension Change where Base: UIActivityIndicatorView {
  func color(_ h: @escaping @autoclosure ()->UIColor?) {
    theme(#function) { $0.color = h() }
  }
}
