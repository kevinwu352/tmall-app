//
//  UILabel_Style.swift
//  ModCommon
//
//  Created by Kevin Wu on 2022/1/1.
//

import UIKit
import Atributika
import AtributikaViews

public class StyLabel: UILabel {

  public override var text: String? {
    get { txt }
    set { txt = newValue }
  }
  var txt: String? {
    didSet { reload(txt) }
  }
  @objc public func reload(_ val: String?) {
    let str = val ?? txt
    reloadText?(str)
    reloadMark?(str)
  }
  public func setNeedsReload() {
    NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(reload), object: nil)
    perform(#selector(reload), with: nil, afterDelay: 0)
  }


  public var fnt: (()->UIFont?)? {
    didSet { setNeedsReload() }
  }
  public var clr: (()->UIColor?)? {
    didSet { setNeedsReload() }
  }
  public var alignment: NSTextAlignment? {
    didSet { setNeedsReload() }
  }
  public var breakMode: NSLineBreakMode? {
    didSet { setNeedsReload() }
  }
  public var lineHeight: Double? {
    didSet { setNeedsReload() }
  }
  public var lineSpacing: Double? {
    didSet { setNeedsReload() }
  }
  public var paragraphSpacing: (Double?,Double?)? {
    didSet { setNeedsReload() }
  }
  public var config: ((inout [NSAttributedString.Key:Any])->Void)? {
    didSet { setNeedsReload() }
  }

  public var reloadText: ((String?)->Void)?

  public func setTextStyles(font: @escaping @autoclosure ()->UIFont?,
                            color: @escaping @autoclosure ()->UIColor?,
                            alignment: NSTextAlignment = .left,
                            breakMode: NSLineBreakMode = .byWordWrapping,
                            lineHeight: Double? = nil,
                            lineSpacing: Double? = nil,
                            paragraphSpacing: (Double?,Double?)? = nil,
                            config: ((inout [NSAttributedString.Key:Any])->Void)? = nil
  ) {
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
  public func setTextStyles(font: @escaping (String?)->UIFont?,
                            color: @escaping (String?)->UIColor?,
                            alignment: NSTextAlignment = .left,
                            breakMode: NSLineBreakMode = .byWordWrapping,
                            lineHeight: Double? = nil,
                            lineSpacing: Double? = nil,
                            paragraphSpacing: (Double?,Double?)? = nil,
                            config: ((inout [NSAttributedString.Key:Any])->Void)? = nil
  ) {
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
    reloadMark = nil
    reload(nil)
  }


  public var tags: (()->[String:Attrs]?)? {
    didSet { setNeedsReload() }
  }
  public var base: (()->Attrs?)? {
    didSet { setNeedsReload() }
  }

  public var reloadMark: ((String?)->Void)?

  public func setMarkStyles(tags: @escaping @autoclosure ()->[String:Attrs],
                            base: @escaping @autoclosure ()->Attrs
  ) {
    setMarkStyles(tags: { _ in tags() }, base: { _ in base() })
  }
  public func setMarkStyles(tags: @escaping (String?)->[String:Attrs],
                            base: @escaping (String?)->Attrs
  ) {
    reloadText = nil
    reloadMark = { [weak self] in
      guard let self = self else { return }
      let str = $0 ?? ""
      self.attributedText = str
        .style(tags: self.tags?() ?? tags(str))
        .styleBase(self.base?() ?? base(str))
        .attributedString
    }
    reload(nil)
  }
}


public class AttLabel: AttributedLabel {

  public override var text: String? {
    get { txt }
    set { txt = newValue }
  }
  var txt: String? {
    didSet { reload(txt) }
  }
  @objc public func reload(_ val: String?) {
    let str = val ?? txt
    reloadMark?(str)
  }
  public func setNeedsReload() {
    NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(reload), object: nil)
    perform(#selector(reload), with: nil, afterDelay: 0)
  }


  public var tags: (()->[String:Attrs]?)? {
    didSet { setNeedsReload() }
  }
  public var high: (()->Attrs?)? {
    didSet { setNeedsReload() }
  }
  public var base: (()->Attrs?)? {
    didSet { setNeedsReload() }
  }

  public var linkDetectionEnabled = true

  public var reloadMark: ((String?)->Void)?

  public func setMarkStyles(tags: @escaping @autoclosure ()->[String:Attrs],
                            high: @escaping @autoclosure ()->Attrs,
                            base: @escaping @autoclosure ()->Attrs
  ) {
    setMarkStyles(tags: { _ in tags() }, high: { _ in high() }, base: { _ in base() })
  }
  // a, @, #
  public func setMarkStyles(tags: @escaping (String?)->[String:Attrs],
                            high: @escaping (String?)->Attrs,
                            base: @escaping (String?)->Attrs
  ) {
    reloadMark = { [weak self] in
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
      var asb = str
        .style(tags: tags)
      //.styleLinks(dt)
      //.styleMentions(dt)
      //.styleHashtags(dt)
      //.styleBase(...)
      if let link = link as? Attrs, linkDetectionEnabled {
        let dt = DetectionTuner { Attrs(link).akaLink($0.text) }
        asb = asb.styleLinks(dt)
      }
      if let mention = mention as? Attrs {
        let dt = DetectionTuner { Attrs(mention).akaLink($0.text) }
        asb = asb.styleMentions(dt)
      }
      if let hashtag = hashtag as? Attrs {
        let dt = DetectionTuner { Attrs(hashtag).akaLink($0.text) }
        asb = asb.styleHashtags(dt)
      }
      self.attributedText = asb
        .styleBase(self.base?() ?? base(str))
        .attributedString
    }
    reload(nil)
  }
}
