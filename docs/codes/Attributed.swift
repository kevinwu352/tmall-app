//
//  Attributed.swift
//  AppCommon
//
//  Created by Kevin Wu on 2022/1/1.
//

import UIKit

public func attrmak(_ base: [NSAttributedString.Key:Any],
                    _ config: (inout [NSAttributedString.Key:Any])->Void
) -> [NSAttributedString.Key:Any] {
  var attrs = base
  config(&attrs)
  return attrs
}

public func attrspc(_ width: Double) -> NSAttributedString {
  // 8r 字体的宽度大概是 2.45
  NSAttributedString(string: " ", attributes: [.font: UIFont.systemFont(ofSize: 8, weight: .regular), .kern: width-3.0])
}

public extension UIImage {

  func attributed(_ attrs: [NSAttributedString.Key:Any]?) -> NSAttributedString {
    let attachment = NSTextAttachment()
    attachment.image = self
    attachment.bounds = .rect_size(size)
    let str = NSMutableAttributedString(attachment: attachment)
    if let attrs = attrs, attrs.notEmpty {
      str.addAttributes(attrs, range: NSRange(location: 0, length: str.length))
    }
    return str
  }

}

public extension Dictionary where Key == NSAttributedString.Key, Value == Any {

  mutating func font(_ font: UIFont?) {
    self[.font] = font
  }
  // UIColor, default blackColor
  mutating func foregroundColor(_ color: UIColor?) {
    self[.foregroundColor] = color
  }

  // NSParagraphStyle, default defaultParagraphStyle
  // lineSpacing: CGFloat         // 单行时没效果，多行时中间有
  // paragraphSpacing: CGFloat    // 单段时没效果，多段时中间有
  // alignment: NSTextAlignment
  // firstLineHeadIndent: CGFloat
  // headIndent: CGFloat
  // tailIndent: CGFloat
  // lineBreakMode: NSLineBreakMode
  // minimumLineHeight: CGFloat
  // maximumLineHeight: CGFloat
  // baseWritingDirection: NSWritingDirection
  // lineHeightMultiple: CGFloat
  // paragraphSpacingBefore: CGFloat
  // hyphenationFactor: Float
  mutating func paragraphStyle(_ h: ((NSMutableParagraphStyle)->Void)?) {
    if let h = h {
      var style: NSMutableParagraphStyle?
      if let paragraph = self[.paragraphStyle] as? NSMutableParagraphStyle {
        style = paragraph
      } else if let paragraph = self[.paragraphStyle] as? NSParagraphStyle {
        style = paragraph.mutableCopy() as? NSMutableParagraphStyle
      } else {
        style = NSMutableParagraphStyle.default.mutableCopy() as? NSMutableParagraphStyle
      }
      if let style = style {
        h(style)
        self[.paragraphStyle] = style
      }
    } else {
      self[.paragraphStyle] = nil
    }
  }

  // UIColor, default nil: no background
  // 有文字的部分才有颜色，如果字符串 1.5 行，第二行只有前半截是背景色
  mutating func backgroundColor(_ color: UIColor?) {
    self[.backgroundColor] = color
  }
  // NSNumber containing floating point value, in points; amount to modify default kerning. 0 means kerning is disabled.
  // 字符间距，正负扩缩
  // "b" 设置字符间距时，间距在后面，展示出来的最终效果是 "b  "
  mutating func kern(_ kern: Double?) {
    self[.kern] = kern
  }
  // NSNumber containing integer, default 1: default ligatures, 0: no ligatures
  // 1默认的连体字符，0不使用，2使用所有连体符号（iOS 不支持）
  mutating func ligature(_ ligature: Bool?) {
    if let ligature = ligature {
      self[.ligature] = ligature ? 1 : 0
    } else {
      self[.ligature] = nil
    }
  }
  // NSNumber containing floating point value, in points; offset from baseline, default 0
  // 基线偏移值，正值上偏，负值下偏
  mutating func baselineOffset(_ offset: Double?) {
    self[.baselineOffset] = offset
  }
  // NSNumber containing floating point value; skew to be applied to glyphs, default 0: no skew
  // 字体倾斜度，正值右倾，负值左倾
  mutating func obliqueness(_ obliqueness: Double?) {
    self[.obliqueness] = obliqueness
  }
  // NSNumber containing floating point value; log of expansion factor to be applied to glyphs, default 0: no expansion
  // 字体横向拉伸，正值拉伸，负值压缩
  mutating func expansion(_ expansion: Double?) {
    self[.expansion] = expansion
  }
  // NSString, default nil: no text effect
  // 文本特殊效果，目前只有一个凸版印刷效果
  mutating func textEffect(_ effect: NSAttributedString.TextEffectStyle?) {
    self[.textEffect] = effect?.rawValue
  }

  // NSNumber containing integer, default 0: no underline
  mutating func underlineStyle(_ style: NSUnderlineStyle?) {
    self[.underlineStyle] = style?.rawValue
  }
  // UIColor, default nil: same as foreground color
  mutating func underlineColor(_ color: UIColor?) {
    self[.underlineColor] = color
  }

  // NSNumber containing integer, default 0: no strikethrough
  mutating func strikethroughStyle(_ style: NSUnderlineStyle?) {
    self[.strikethroughStyle] = style?.rawValue
  }
  // UIColor, default nil: same as foreground color
  mutating func strikethroughColor(_ color: UIColor?) {
    self[.strikethroughColor] = color
  }

  // NSNumber containing floating point value, in percent of font point size, default 0: no stroke; positive for stroke alone, negative for stroke and fill (a typical value for outlined text would be 3.0)
  // 正值中空，描边的颜色是此颜色
  // 负值填充，描边的颜色是此颜色，中间填充的颜色是 foreground
  mutating func strokeWidth(_ width: Double?) {
    self[.strokeWidth] = width
  }
  // UIColor, default nil: same as foreground color
  mutating func strokeColor(_ color: UIColor?) {
    self[.strokeColor] = color
  }

  // NSShadow, default nil: no shadow
  mutating func shadow(_ h: ((NSShadow)->Void)?) {
    if let h = h {
      let shadow = self[.shadow] as? NSShadow ?? NSShadow()
      h(shadow)
      self[.shadow] = shadow
    } else {
      self[.shadow] = nil
    }
  }


  // link:
  // NSURL (preferred) or NSString

  // attachment:
  // NSTextAttachment, default nil

  // tracking: iOS 14
  // NSNumber containing floating point value, in points; amount to modify default tracking. 0 means tracking is disabled.

  // writingDirection:
  // NSArray of NSNumbers representing the nested levels of writing direction overrides as defined by Unicode LRE, RLE, LRO, and RLO characters.  The control characters can be obtained by masking NSWritingDirection and NSWritingDirectionFormatType values.  LRE: NSWritingDirectionLeftToRight|NSWritingDirectionEmbedding, RLE: NSWritingDirectionRightToLeft|NSWritingDirectionEmbedding, LRO: NSWritingDirectionLeftToRight|NSWritingDirectionOverride, RLO: NSWritingDirectionRightToLeft|NSWritingDirectionOverride,

  // verticalGlyphForm:
  // An NSNumber containing an integer value.  0 means horizontal text.  1 indicates vertical text.  If not specified, it could follow higher-level vertical orientation settings.  Currently on iOS, it's always horizontal.  The behavior for any other value is undefined.

}
