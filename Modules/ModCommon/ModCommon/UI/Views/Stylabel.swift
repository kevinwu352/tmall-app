//
//  Stylabel.swift
//  ModCommon
//
//  Created by Kevin Wu on 2022/1/1.
//

import UIKit
import Atributika
import AtributikaViews

#if DEBUG
public class Labels {
  public init() { }

  public func run() {
    lb2.text = "aa bb cc"

    lb3.text = "aa <b>bb</b> cc <p>dd</p> ee"

    lb4.text = """
        It is called <a href="http://www.atributika.com">Atributika</a>. @all I
        found #swift #nsattributedstring really nice framework to manage attributed strings.
        Call me if you want to <b>know</b> <p>more</p> (123)456-7890 https://github.com/psharanda/Atributika
        """

    lb4.onLinkTouchUpInside = { _, val in
      if let link = val as? String {
        // ...
      }
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
  public lazy var lb2: Stylabel = {
    let ret = Stylabel()
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
  /*
   lb2.fnt = .boldSystemFont(ofSize: 14)
   lb2.clr = .green
   lb2.alignment = .right
   lb2.breakMode = .byCharWrapping
   lb2.lineSpacing = 20
   lb2.paragraphSpacing = (10, 10)
   lb2.config = {
   $0[.underlineStyle] = NSUnderlineStyle.thick.rawValue
   $0[.underlineColor] = UIColor.red
   }
   */

  // different style for each markup
  public lazy var lb3: Stylabel = {
    let ret = Stylabel()
    ret.setMarkupStyles(
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
  public lazy var lb4: Attlabel = {
    let ret = Attlabel()
    //ret.linkDetectionEnabled = false
    ret.setMarkupStyles(
      tags: [
        "a": .init().foregroundColor(.red),
        "@": .init().foregroundColor(.green),
        "#": .init().foregroundColor(.blue),
        "b": .init().font(.boldSystemFont(ofSize: 14)),
        "p": .init().foregroundColor(.purple),
      ],
      high: .init().foregroundColor(.magenta),
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
#endif

// NSLineBreakMode.byTruncatingTail 只说了如何截取，它隐含的换行模式是 .byWordWrapping

// textAlignment 和 lineBreakMode 在 attributed 中也会起作用

public class Stylabel: UILabel {

  public override var text: String? {
    get { txt }
    set { txt = newValue }
  }
  var txt: String? {
    didSet { reload(txt) }
  }
  public func reload(_ val: String?) {
    let str = val ?? txt
    reloadText?(str)
    reloadMarkup?(str)
  }

  public func setNeedsRefresh() {
    setNeeds(#selector(refresh))
  }
  @objc public func refresh() {
    reload(nil)
  }


  public var fnt: (()->UIFont?)? {
    didSet { setNeedsRefresh() }
  }
  public var clr: (()->UIColor?)? {
    didSet { setNeedsRefresh() }
  }
  public var alignment: NSTextAlignment? {
    didSet { setNeedsRefresh() }
  }
  public var breakMode: NSLineBreakMode? {
    didSet { setNeedsRefresh() }
  }
  public var lineHeight: Double? {
    didSet { setNeedsRefresh() }
  }
  public var lineSpacing: Double? {
    didSet { setNeedsRefresh() }
  }
  public var paragraphSpacing: (Double?,Double?)? {
    didSet { setNeedsRefresh() }
  }
  public var config: ((inout [NSAttributedString.Key:Any])->Void)? {
    didSet { setNeedsRefresh() }
  }

  public var reloadText: ((String?)->Void)? // CLOS

  public func setTextStyles(font: @escaping (String?)->UIFont?,
                            color: @escaping (String?)->UIColor?,
                            alignment: NSTextAlignment = .left,
                            breakMode: NSLineBreakMode = .byWordWrapping,
                            lineHeight: Double? = nil,
                            lineSpacing: Double? = nil,
                            paragraphSpacing: (Double?,Double?)? = nil,
                            config: ((inout [NSAttributedString.Key:Any])->Void)? = nil
  ) { // FUNC
    reloadMarkup = nil
    reloadText = { [weak self] in
      guard let self = self else { return }
      let str = $0 ?? ""
      var attrs: [NSAttributedString.Key:Any] = [:]
      attrs[.font] = self.fnt?() ?? font(str)
      attrs[.foregroundColor] = self.clr?() ?? color(str)

      let paragraph = NSMutableParagraphStyle.fromBase(base: nil)
      paragraph.alignment = self.alignment ?? alignment
      paragraph.lineBreakMode = self.breakMode ?? breakMode
      if let lineHeight = self.lineHeight ?? lineHeight {
        paragraph.minimumLineHeight = lineHeight
        attrs[.baselineOffset] = (lineHeight - ((self.fnt?() ?? font(str))?.lineHeight ?? 0)) / 2
      }
      if let lineSpacing = self.lineSpacing ?? lineSpacing {
        paragraph.lineSpacing = lineSpacing
      }
      //段间距=前段后+此段前，首段前尾段后没有间距
      let paragraphSpacing = self.paragraphSpacing ?? paragraphSpacing
      if let before = paragraphSpacing?.0 {
        paragraph.paragraphSpacingBefore = before
      }
      if let after = paragraphSpacing?.1 {
        paragraph.paragraphSpacing = after
      }
      attrs[.paragraphStyle] = paragraph

      (self.config ?? config)?(&attrs)

      self.attributedText = NSAttributedString(string: str, attributes: attrs)
    }
    reload(nil)
  }
  public func setTextStyles(font: @escaping @autoclosure ()->UIFont?,
                            color: @escaping @autoclosure ()->UIColor?,
                            alignment: NSTextAlignment = .left,
                            breakMode: NSLineBreakMode = .byWordWrapping,
                            lineHeight: Double? = nil,
                            lineSpacing: Double? = nil,
                            paragraphSpacing: (Double?,Double?)? = nil,
                            config: ((inout [NSAttributedString.Key:Any])->Void)? = nil
  ) { // FUNC
    setTextStyles(font: { _ in font() },
                  color: { _ in color() },
                  alignment: alignment,
                  breakMode: breakMode,
                  lineHeight: lineHeight,
                  lineSpacing: lineSpacing,
                  paragraphSpacing: paragraphSpacing,
                  config: config
    )
  }


  public var tags: (()->[String:Attrs]?)? {
    didSet { setNeedsRefresh() }
  }
  public var base: (()->Attrs?)? {
    didSet { setNeedsRefresh() }
  }

  public var reloadMarkup: ((String?)->Void)? // CLOS

  public func setMarkupStyles(tags: @escaping (String?)->[String:Attrs],
                              base: @escaping (String?)->Attrs
  ) { // FUNC
    reloadText = nil
    reloadMarkup = { [weak self] in
      guard let self = self else { return }
      let str = $0 ?? ""
      self.attributedText = str
        .style(tags: self.tags?() ?? tags(str))
        .styleBase(self.base?() ?? self.styles(base(str)))
        .attributedString
    }
    reload(nil)
  }
  public func setMarkupStyles(tags: @escaping @autoclosure ()->[String:Attrs],
                              base: @escaping @autoclosure ()->Attrs
  ) { // FUNC
    setMarkupStyles(tags: { _ in tags() }, base: { _ in base() })
  }
  func styles(_ attrs: Attrs) -> Attrs {
    if let fnt = fnt?() {
      attrs.font(fnt)
    }
    if let clr = clr?() {
      attrs.foregroundColor(clr)
    }
    let paragraph = attrs.attributes[.paragraphStyle] as? NSMutableParagraphStyle
    if let alignment = alignment {
      paragraph?.alignment = alignment
    }
    if let breakMode = breakMode {
      paragraph?.lineBreakMode = breakMode
    }
    if let lineHeight = lineHeight {
      paragraph?.minimumLineHeight = lineHeight
    }
    if let lineHeight = paragraph?.minimumLineHeight, let font = attrs.attributes[.font] as? UIFont {
      let offset = (lineHeight - font.lineHeight) / 2
      attrs.baselineOffset(Float(offset))
    }
    if let lineSpacing = lineSpacing {
      paragraph?.lineSpacing = lineSpacing
    }
    if let before = paragraphSpacing?.0 {
      paragraph?.paragraphSpacingBefore = before
    }
    if let after = paragraphSpacing?.1 {
      paragraph?.paragraphSpacing = after
    }
    if let paragraph = paragraph {
      attrs.paragraphStyle(paragraph)
    }
    return attrs
  }
}


public class Attlabel: AttributedLabel {

  public override var text: String? {
    get { txt }
    set { txt = newValue }
  }
  var txt: String? {
    didSet { reload(txt) }
  }
  public func reload(_ val: String?) {
    let str = val ?? txt
    reloadMarkup?(str)
  }

  public func setNeedsRefresh() {
    setNeeds(#selector(refresh))
  }
  @objc public func refresh() {
    reload(nil)
  }


  public var tags: (()->[String:Attrs]?)? {
    didSet { setNeedsRefresh() }
  }
  public var high: (()->Attrs?)? {
    didSet { setNeedsRefresh() }
  }
  public var base: (()->Attrs?)? {
    didSet { setNeedsRefresh() }
  }

  public var linkDetectionEnabled = true

  public var reloadMarkup: ((String?)->Void)? // CLOS

  // a, @, #
  public func setMarkupStyles(tags: @escaping (String?)->[String:Attrs],
                              high: @escaping (String?)->Attrs,
                              base: @escaping (String?)->Attrs
  ) { // FUNC
    reloadMarkup = { [weak self] in
      guard let self = self else { return }
      let str = $0 ?? ""
      self.highlightedLinkAttributes = (self.high?() ?? high(str)).attributes
      var tags = (self.tags?() ?? tags(str)) as [String:TagTuning]
      let link = tags.removeValue(forKey: "a")
      let mention = tags.removeValue(forKey: "@")
      let hashtag = tags.removeValue(forKey: "#")
      if let a = link as? Attrs {
        tags["a"] = TagTuner {
          Attrs(a).akaLink($0.tag.attributes["href"] ?? "")
        }
      }
      var builder = str.style(tags: tags)
      if let link = link as? Attrs, linkDetectionEnabled {
        builder = builder.styleLinks(DetectionTuner(style: {
          Attrs(link).akaLink($0.text)
        }))
      }
      if let mention = mention as? Attrs {
        builder = builder.styleMentions(DetectionTuner(style: {
          Attrs(mention).akaLink($0.text)
        }))
      }
      if let hashtag = hashtag as? Attrs {
        builder = builder.styleHashtags(DetectionTuner(style: {
          Attrs(hashtag).akaLink($0.text)
        }))
      }
      self.attributedText = builder
        .styleBase(self.base?() ?? base(str))
        .attributedString
    }
    reload(nil)
  }
  public func setMarkupStyles(tags: @escaping @autoclosure ()->[String:Attrs],
                              high: @escaping @autoclosure ()->Attrs,
                              base: @escaping @autoclosure ()->Attrs
  ) { // FUNC
    setMarkupStyles(tags: { _ in tags() }, high: { _ in high() }, base: { _ in base() })
  }
}
