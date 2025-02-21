//
//  UIButton_Style.swift
//  ModCommon
//
//  Created by Kevin Wu on 2022/1/1.
//

import UIKit
import CoreImage.CIFilterBuiltins

public extension UIButton {

  static func primary(_ title: @escaping @autoclosure ()->String?) -> UIButton {
    let ret = UIButton(configuration: .plain())
    ret.style(image: .init({ _ in (R.image.shared.alien.cur?.template, .red) }).high(),
              title: .init({ _ in title() }, { _ in .h1 }, { _ in .red }).high(),
              background: .init({ _ in (R.image.shared.alien.cur, UIEdgeInsets(top: 0, left: 25, bottom: 0, right: 25)) }).high()
    )
    return ret
  }

}

public extension UIControl.State {
  var name: String {
    switch self {
    case .normal: return "normal"               // 0
    case .highlighted: return "highlighted"     // 1
    case .disabled: return "disabled"           // 2
    case .selected: return "selected"           // 4
    case .focused: return "focused"             // 8
    case .application: return "application"     // 16711680
    case .reserved: return "reserved"           // 4278190080
    default: return "unknown \(rawValue)"
    }
  }
}

public extension UIButton {

  enum Status {
    case normal
    case highlighted
    case disabled
    public init(_ state: UIControl.State) {
      if state == .highlighted || state == .selected {
        self = .highlighted
      } else if state == .disabled {
        self = .disabled
      } else {
        if state.rawValue == UIControl.State.highlighted.rawValue | UIControl.State.selected.rawValue { // 5
          self = .highlighted
        } else {
          self = .normal
        }
      }
    }
    public var norm: Bool { self == .normal }
    public var high: Bool { self == .highlighted }
    public var dis: Bool { self == .disabled }
  }

  // 系统高亮
  //   (template, color)，务必给个颜色，否则会用系统某个颜色值。（如果传 original，颜色不起作用）
  // 自动高亮
  //   (original, nil  ).high()，不给颜色，用图片算出一个高亮图片。（不准传 template）
  //   (template, color).high()，要给颜色，用颜色算出一个高亮颜色。（不准传 original）
  class Icon {
    var image: (Status)->(UIImage?,UIColor?)
    public init(_ image: @escaping (Status)->(UIImage?,UIColor?)) {
      self.image = image
    }
    public convenience init(_ image: @escaping @autoclosure ()->(UIImage?,UIColor?)) {
      self.init({ _ in image() })
    }

    var spacing: ((Status)->Double?)?
    var alignment: ((Status)->NSDirectionalRectEdge?)?
    public func layout(_ spacing: @escaping (Status)->Double?, _ alignment: @escaping (Status)->NSDirectionalRectEdge?) -> Self {
      self.spacing = spacing
      self.alignment = alignment
      return self
    }
    public func layout(_ spacing: @escaping (Status)->Double?, _ alignment: @escaping @autoclosure ()->NSDirectionalRectEdge?) -> Self {
      layout(spacing, { _ in alignment() })
    }
    public func layout(_ spacing: @escaping @autoclosure ()->Double?, _ alignment: @escaping (Status)->NSDirectionalRectEdge?) -> Self {
      layout({ _ in spacing() }, alignment)
    }
    public func layout(_ spacing: @escaping @autoclosure ()->Double?, _ alignment: @escaping @autoclosure ()->NSDirectionalRectEdge?) -> Self {
      layout({ _ in spacing() }, { _ in alignment() })
    }

    var autohigh = false
    public func high() -> Self {
      autohigh = true
      return self
    }
  }

  class Text {
    var str: (Status)->String?
    var font: (Status)->UIFont?
    var color: (Status)->UIColor?
    public init(_ str: @escaping (Status)->String?, _ font: @escaping (Status)->UIFont?, _ color: @escaping (Status)->UIColor?) {
      self.str = str
      self.font = font
      self.color = color
    }
    public convenience init(_ str: @escaping (Status)->String?, _ font: @escaping (Status)->UIFont?, _ color: @escaping @autoclosure ()->UIColor?) {
      self.init(str, font, { _ in color() })
    }
    public convenience init(_ str: @escaping (Status)->String?, _ font: @escaping @autoclosure ()->UIFont?, _ color: @escaping (Status)->UIColor?) {
      self.init(str, { _ in font() }, color)
    }
    public convenience init(_ str: @escaping @autoclosure ()->String?, _ font: @escaping (Status)->UIFont?, _ color: @escaping (Status)->UIColor?) {
      self.init({ _ in str() }, font, color)
    }
    public convenience init(_ str: @escaping (Status)->String?, _ font: @escaping @autoclosure ()->UIFont?, _ color: @escaping @autoclosure ()->UIColor?) {
      self.init(str, { _ in font() }, { _ in color() })
    }
    public convenience init(_ str: @escaping @autoclosure ()->String?, _ font: @escaping (Status)->UIFont?, _ color: @escaping @autoclosure ()->UIColor?) {
      self.init({ _ in str() }, font, { _ in color() })
    }
    public convenience init(_ str: @escaping @autoclosure ()->String?, _ font: @escaping @autoclosure ()->UIFont?, _ color: @escaping (Status)->UIColor?) {
      self.init({ _ in str() }, { _ in font() }, color)
    }
    public convenience init(_ str: @escaping @autoclosure ()->String?, _ font: @escaping @autoclosure ()->UIFont?, _ color: @escaping @autoclosure ()->UIColor?) {
      self.init({ _ in str() }, { _ in font() }, { _ in color() })
    }

    var spacing: ((Status)->Double?)?
    var alignment: ((Status)->Configuration.TitleAlignment?)?
    public func layout(_ spacing: @escaping (Status)->Double?, _ alignment: @escaping (Status)->Configuration.TitleAlignment?) -> Self {
      self.spacing = spacing
      self.alignment = alignment
      return self
    }
    public func layout(_ spacing: @escaping (Status)->Double?, _ alignment: @escaping @autoclosure ()->Configuration.TitleAlignment?) -> Self {
      layout(spacing, { _ in alignment() })
    }
    public func layout(_ spacing: @escaping @autoclosure ()->Double?, _ alignment: @escaping (Status)->Configuration.TitleAlignment?) -> Self {
      layout({ _ in spacing() }, alignment)
    }
    public func layout(_ spacing: @escaping @autoclosure ()->Double?, _ alignment: @escaping @autoclosure ()->Configuration.TitleAlignment?) -> Self {
      layout({ _ in spacing() }, { _ in alignment() })
    }

    var autohigh = false
    public func high() -> Self {
      autohigh = true
      return self
    }
  }

  class Background {
    var color: ((Status)->UIColor?)?
    public init(_ color: @escaping (Status)->UIColor?) {
      self.color = color
    }
    public convenience init(_ color: @escaping @autoclosure ()->UIColor?) {
      self.init({ _ in color() })
    }

    var image: ((Status)->(UIImage?,UIEdgeInsets?))?
    public init(_ image: @escaping (Status)->(UIImage?,UIEdgeInsets?)) {
      self.image = image
    }
    public convenience init(_ image: @escaping @autoclosure ()->(UIImage?,UIEdgeInsets?)) {
      self.init({ _ in image() })
    }

    var cornerRadius: ((Status)->Double?)?
    public func corner(_ radius: @escaping (Status)->Double?) -> Self {
      cornerRadius = radius
      return self
    }
    public func corner(_ radius: @escaping @autoclosure ()->Double?) -> Self {
      corner({ _ in radius() })
    }

    var borderWidth: ((Status)->Double?)?
    var borderColor: ((Status)->UIColor?)?
    public func border(_ width: @escaping (Status)->Double?, _ color: @escaping (Status)->UIColor?) -> Self {
      borderWidth = width
      borderColor = color
      return self
    }
    public func border(_ width: @escaping (Status)->Double?, _ color: @escaping @autoclosure ()->UIColor?) -> Self {
      border(width, { _ in color() })
    }
    public func border(_ width: @escaping @autoclosure ()->Double?, _ color: @escaping (Status)->UIColor?) -> Self {
      border({ _ in width() }, color)
    }
    public func border(_ width: @escaping @autoclosure ()->Double?, _ color: @escaping @autoclosure ()->UIColor?) -> Self {
      border({ _ in width() }, { _ in color() })
    }

    var autohigh = false
    public func high() -> Self {
      autohigh = true
      return self
    }
  }

  func style(image: Icon?,
             title: Text?,
             subtitle: Text? = nil,
             background: Background? = nil,
             insets: NSDirectionalEdgeInsets? = nil
  ) { // [FUNC]
    configurationUpdateHandler = { [weak self] in
      var config = $0.configuration ?? .plain()
      let status = Status($0.state)

      if let img = (self as? Stybutton)?.image {
        config.image = img.0
        config.baseForegroundColor = img.1
      } else if let img_h = image?.image {
        let img = img_h(status)
        if image?.autohigh == true {
          if img.1 != nil {
            config.image = img.0
            config.baseForegroundColor = img.1?.turn(status.high)
          } else {
            config.image = img.0?.turn(status.high, nil)
          }
        } else {
          config.image = img.0
          config.baseForegroundColor = img.1
        }
      }
      if let spacing = image?.spacing?(status) {
        config.imagePadding = spacing
      }
      if let alignment = image?.alignment?(status) {
        config.imagePlacement = alignment
      }

      if let txt = (self as? Stybutton)?.title ?? title?.str(status) {
        config.attributedTitle = txt.attributed(
          title?.font(status),
          title?.color(status)?.turn(status.high && title?.autohigh == true)
        )
      }
      if let spacing = title?.spacing?(status) {
        config.titlePadding = spacing
      }
      if let alignment = title?.alignment?(status) {
        config.titleAlignment = alignment
      }

      if let txt = (self as? Stybutton)?.subtitle ?? subtitle?.str(status) {
        config.attributedSubtitle = txt.attributed(
          subtitle?.font(status),
          subtitle?.color(status)?.turn(status.high && subtitle?.autohigh == true)
        )
      }

      // config.baseBackgroundColor
      if let clr = (self as? Stybutton)?.bgcolor {
        config.background.backgroundColor = clr
      } else if let clr_h = background?.color {
        config.background.backgroundColor = clr_h(status)?.turn(status.high && background?.autohigh == true)
      }
      if let img = (self as? Stybutton)?.bgimage {
        config.background.image = img.0?.inset(img.1)
      } else if let img_h = background?.image {
        let img = img_h(status)
        config.background.image = img.0?.turn(status.high && background?.autohigh == true, img.1)
      }
      if let cornerRadius = background?.cornerRadius?(status) {
        config.background.cornerRadius = cornerRadius
      }
      if let borderWidth = background?.borderWidth?(status) {
        config.background.strokeWidth = borderWidth
      }
      if let borderColor = background?.borderColor?(status) {
        config.background.strokeColor = borderColor
      }

      if let insets = insets {
        config.contentInsets = insets
      }

      $0.configuration = config
    }
  }

}

public class Stybutton: UIButton {
  public var image: (UIImage?,UIColor?)? {
    didSet { setNeedsUpdateConfiguration() }
  }
  public var title: String? {
    didSet { setNeedsUpdateConfiguration() }
  }
  public var subtitle: String? {
    didSet { setNeedsUpdateConfiguration() }
  }
  public var bgcolor: UIColor? {
    didSet { setNeedsUpdateConfiguration() }
  }
  public var bgimage: (UIImage?,UIEdgeInsets?)? {
    didSet { setNeedsUpdateConfiguration() }
  }
}

fileprivate extension UIColor {
  func turn(_ flag: Bool) -> UIColor {
    flag ? withAlphaComponent(0.75) : self
  }
}
fileprivate extension UIImage {
  func turn(_ flag: Bool, _ insets: UIEdgeInsets?) -> UIImage {
    (flag ? brighted(0.05) : self).inset(insets)
  }
}

public extension UIImage {
  // -1: black, 1: white
  func brighted(_ val: Double) -> UIImage {
    let filter = CIFilter.colorControls()
    filter.inputImage = CIImage(image: self)
    filter.brightness = Float(val)
    if let ciimg = filter.outputImage,
       let cgimg = CIContext(options: nil).createCGImage(ciimg, from: ciimg.extent)
    {
      let img = UIImage(cgImage: cgimg, scale: scale, orientation: .up)
      return img
    }
    return self
  }
  func inset(_ insets: UIEdgeInsets?) -> UIImage {
    if let insets = insets {
      return resizableImage(withCapInsets: insets, resizingMode: .stretch)
    } else {
      return self
    }
  }
}
