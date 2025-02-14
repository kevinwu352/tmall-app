//
//  UIButtonExt.swift
//  ModCommon
//
//  Created by Kevin Wu on 2022/1/1.
//

import UIKit

// TODO: delete
public extension UIButton {

  var contentInsets: UIEdgeInsets {
    get {
      if #available(iOS 15.0, *) {
        if let configuration = configuration {
          return configuration.contentInsets.indirectional
        } else {
          return .zero
        }
      } else {
        return contentEdgeInsets
      }
    }
    set {
      if #available(iOS 15.0, *) {
        var config = configuration ?? Configuration.plain()
        config.contentInsets = newValue.directional
        configuration = config
      } else {
        contentEdgeInsets = newValue
      }
    }
  }

}

public extension UIButton {

  // 图文间距，是否交换
  // 两边会超过边界
  func horHug(_ space: Double, _ swap: Bool) {
    imageEdgeInsets = .zero
    titleEdgeInsets = .zero
    layoutIfNeeded()

    let image_width = imageView?.image?.size.width ?? 0
    let title_width = titleLabel?.frame.width ?? 0

    let offset = space / 2
    if swap {
      let image_offset = title_width + offset
      imageEdgeInsets = UIEdgeInsets(top: 0, left: image_offset, bottom: 0, right: -image_offset)
      let title_offset = image_width + offset
      titleEdgeInsets = UIEdgeInsets(top: 0, left: -title_offset, bottom: 0, right: title_offset)
    } else {
      imageEdgeInsets = UIEdgeInsets(top: 0, left: -offset, bottom: 0, right: offset)
      titleEdgeInsets = UIEdgeInsets(top: 0, left: offset, bottom: 0, right: -offset)
    }
  }

  // 图文边距，是否交换
  func horExpand(_ margin: Double, _ swap: Bool) {
    imageEdgeInsets = .zero
    titleEdgeInsets = .zero
    layoutIfNeeded()

    let image_width = imageView?.image?.size.width ?? 0
    let title_width = titleLabel?.frame.width ?? 0

    let offset = (frame.width - image_width - title_width) / 2 - margin
    if swap {
      let image_offset = title_width + offset
      imageEdgeInsets = UIEdgeInsets(top: 0, left: image_offset, bottom: 0, right: -image_offset)
      let title_offset = image_width + offset
      titleEdgeInsets = UIEdgeInsets(top: 0, left: -title_offset, bottom: 0, right: title_offset)
    } else {
      imageEdgeInsets = UIEdgeInsets(top: 0, left: -offset, bottom: 0, right: offset)
      titleEdgeInsets = UIEdgeInsets(top: 0, left: offset, bottom: 0, right: -offset)
    }
  }


  func verHug(_ space: Double, _ swap: Bool) {
    imageEdgeInsets = .zero
    titleEdgeInsets = .zero
    layoutIfNeeded()

    let iw = imageView?.image?.size.width ?? 0
    let ih = imageView?.image?.size.height ?? 0
    let title_offset_v = (ih + space) / 2
    if swap {
      titleEdgeInsets = UIEdgeInsets(top: -title_offset_v, left: -iw, bottom: title_offset_v, right: 0)
    } else {
      titleEdgeInsets = UIEdgeInsets(top: title_offset_v, left: -iw, bottom: -title_offset_v, right: 0)
    }
    layoutIfNeeded()

    let image_width = imageView?.image?.size.width ?? 0
    //let image_height = imageView?.image?.size.height ?? 0
    let title_width = titleLabel?.frame.width ?? 0
    let title_height = titleLabel?.frame.height ?? 0

    let image_offset_v = (title_height + space) / 2
    if (title_width + image_width) < bounds.width {
      // 放开 title 后，内容宽度能完全被容纳
      let image_offset_h = title_width / 2
      if swap {
        imageEdgeInsets = UIEdgeInsets(top: image_offset_v, left: image_offset_h, bottom: -image_offset_v, right: -image_offset_h)
      } else {
        imageEdgeInsets = UIEdgeInsets(top: -image_offset_v, left: image_offset_h, bottom: image_offset_v, right: -image_offset_h)
      }
    } else {
      // 放开 title 后，内容宽度超过按钮宽度，此时图片一定贴在最左边
      let image_offset_h = (bounds.width - image_width) / 2
      if swap {
        imageEdgeInsets = UIEdgeInsets(top: image_offset_v, left: image_offset_h, bottom: -image_offset_v, right: -image_offset_h)
      } else {
        imageEdgeInsets = UIEdgeInsets(top: -image_offset_v, left: image_offset_h, bottom: image_offset_v, right: -image_offset_h)
      }
    }
  }

  func verExpand(_ margin: Double, _ swap: Bool) {
    imageEdgeInsets = .zero
    titleEdgeInsets = .zero
    layoutIfNeeded()

    let iw = imageView?.image?.size.width ?? 0
    let th = titleLabel?.frame.height ?? 0
    let title_offset_v = (frame.height - th) / 2 - margin
    if swap {
      titleEdgeInsets = UIEdgeInsets(top: -title_offset_v, left: -iw, bottom: title_offset_v, right: 0)
    } else {
      titleEdgeInsets = UIEdgeInsets(top: title_offset_v, left: -iw, bottom: -title_offset_v, right: 0)
    }
    layoutIfNeeded()

    let image_width = imageView?.image?.size.width ?? 0
    let image_height = imageView?.image?.size.height ?? 0
    let title_width = titleLabel?.frame.width ?? 0
    //let title_height = titleLabel?.frame.height ?? 0

    let image_offset_v = (frame.height - image_height) / 2 - margin
    if (title_width + image_width) < bounds.width {
      // 放开 title 后，内容宽度能完全被容纳
      let image_offset_h = title_width / 2
      if swap {
        imageEdgeInsets = UIEdgeInsets(top: image_offset_v, left: image_offset_h, bottom: -image_offset_v, right: -image_offset_h)
      } else {
        imageEdgeInsets = UIEdgeInsets(top: -image_offset_v, left: image_offset_h, bottom: image_offset_v, right: -image_offset_h)
      }
    } else {
      // 放开 title 后，内容宽度超过按钮宽度，此时图片一定贴在最左边
      let image_offset_h = (bounds.width - image_width) / 2
      if swap {
        imageEdgeInsets = UIEdgeInsets(top: image_offset_v, left: image_offset_h, bottom: -image_offset_v, right: -image_offset_h)
      } else {
        imageEdgeInsets = UIEdgeInsets(top: -image_offset_v, left: image_offset_h, bottom: image_offset_v, right: -image_offset_h)
      }
    }
  }

}
