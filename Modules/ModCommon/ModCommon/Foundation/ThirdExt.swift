//
//  ThirdExt.swift
//  ModCommon
//
//  Created by Kevin Wu on 2022/1/1.
//

import UIKit
import RswiftResources
import SnapKit
import Kingfisher

public extension RswiftResources.ImageResource {
  var cur: UIImage? { to(nil) }
  func to(_ to: Theme?) -> UIImage? {
    let nm: String
    if let thm = Theme.allCases.first(where: { name.hasSuffix($0.code) }) {
      nm = name.dropLast(thm.code.count) + (to ?? THEME).code
    } else {
      nm = name
    }
    return RswiftResources.ImageResource(name: nm,
                                         path: path,
                                         bundle: bundle,
                                         locale: locale,
                                         onDemandResourceTags: onDemandResourceTags
    ).callAsFunction()
  }
}
public extension RswiftResources.StringResource {
  var cur: String { to(nil) }
  func to(_ to: Language?) -> String {
    let cd = (to ?? LANGUAGE).code
    return RswiftResources.StringResource(key: key,
                                          tableName: tableName,
                                          source: .init(bundle: source.bundle!, tableName: tableName, preferredLanguages: [cd], locale: nil),
                                          developmentValue: developmentValue,
                                          comment: comment
    ).callAsFunction()
  }
}



public extension ConstraintMaker {
  // 不确定导航条是否存在
  func pin_head(_ anchor: UIView?, _ offset: Double, _ view: UIView, _ padding: Double) {
    if let anchor = anchor {
      top.equalTo(anchor.snp.bottom).offset(offset)
    } else {
      top.equalTo(view.safeAreaLayoutGuide).offset(padding)
    }
  }
  // 确定上边有视图
  func pin_top(_ anchor: UIView?, _ offset: Double) {
    guard let anchor = anchor else { return }
    top.equalTo(anchor.snp.bottom).offset(offset)
  }
  func pin_bottom(_ anchor: UIView?, _ offset: Double) {
    guard let anchor = anchor else { return }
    bottom.equalTo(anchor.snp.top).offset(offset)
  }
  func pin_leading(_ anchor: UIView?, _ offset: Double) {
    guard let anchor = anchor else { return }
    leading.equalTo(anchor.snp.trailing).offset(offset)
  }
  func pin_trailing(_ anchor: UIView?, _ offset: Double) {
    guard let anchor = anchor else { return }
    trailing.equalTo(anchor.snp.leading).offset(offset)
  }
  // make.leading.trailing.equalToSuperview().inset(20)
}



public extension UIImageView {
  func loadImage(_ src: Any?) {
    if let img = src as? UIImage {
      image = img
    } else if let str = src as? String {
      kf.setImage(with: str.url)
    }
  }
}
//public extension UIImage {
//  func process() -> UIImage? {
//    let processor = RoundCornerImageProcessor(radius: .widthFraction(0.5), targetSize: CGSize(width: 200, height: 200))
//                    |> BorderImageProcessor(border: .init(color: UIColor.red, lineWidth: 1, radius: .widthFraction(0.5), roundingCorners: .all))
//    let image = processor.process(item: .image(self), options: .init(KingfisherManager.shared.defaultOptions))
//    return image
//  }
//}
