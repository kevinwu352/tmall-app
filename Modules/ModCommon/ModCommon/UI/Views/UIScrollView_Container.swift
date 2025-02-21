//
//  UIScrollView_Container.swift
//  ModCommon
//
//  Created by Kevin Wu on 2022/1/1.
//

import UIKit
import SnapKit

public extension UIScrollView {

  class ContentView: UIView { }

  var contentView: ContentView? {
    subviews.first(where: { $0 is ContentView }) as? ContentView
  }

  func addContentView(_ axis: NSLayoutConstraint.Axis, _ edges: UIEdgeInsets) {
    if contentView == nil {
      let cv = ContentView()
      addSubview(cv)
    }
    if axis == .vertical {
      showsHorizontalScrollIndicator = false
    } else {
      showsVerticalScrollIndicator = false
    }
    contentView?.snp.remakeConstraints { make in
      make.edges.equalToSuperview().inset(edges)
      if axis.isVertical {
        make.width.equalToSuperview().offset(-edges.horizontal)
      } else {
        make.height.equalToSuperview().offset(-edges.vertical)
      }
    }
  }


  var stackView: UIStackView? {
    subviews.first(where: { $0 is UIStackView }) as? UIStackView
  }

  func addStackView(_ axis: NSLayoutConstraint.Axis, _ edges: UIEdgeInsets) {
    if stackView == nil {
      let sv = UIStackView()
      sv.axis = axis
      sv.alignment = .fill
      sv.distribution = .equalSpacing
      sv.spacing = 0
      addSubview(sv)
    }
    if axis == .vertical {
      showsHorizontalScrollIndicator = false
    } else {
      showsVerticalScrollIndicator = false
    }
    stackView?.snp.remakeConstraints { make in
      make.edges.equalToSuperview().inset(edges)
      if axis.isVertical {
        make.width.equalToSuperview().offset(-edges.horizontal)
      } else {
        make.height.equalToSuperview().offset(-edges.vertical)
      }
    }
  }

}


public extension UIScrollView {
  var pageIndexX: Int {
    guard frame.width > 0 else { return 0 }
    if contentOffset.x + frame.width >= contentSize.width {
      let total = contentSize.width / frame.width
      let index = total.fractions ? total.i : max(total - 1.0, 0.0).i
      return index
    } else {
      let index = (contentOffset.x / frame.width).i
      return index
    }
  }
  var pageIndexY: Int {
    guard frame.height > 0 else { return 0 }
    if contentOffset.y + frame.height >= contentSize.height {
      let total = contentSize.height / frame.height
      let index = total.fractions ? total.i : max(total - 1.0, 0.0).i
      return index
    } else {
      let index = (contentOffset.y / frame.height).i
      return index
    }
  }
}
// 2.01:true, 2.00:false
public extension FloatingPoint {
  var fractions: Bool { self != floor(self) }
}

// func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
//   guard !decelerate else { return }
// }
// func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) { }
// func scrollViewDidScrollToTop(_ scrollView: UIScrollView) { }
