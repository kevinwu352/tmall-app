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
  //
  // make.top.equalTo(navbar?.snp.bottom ?? view.safeAreaLayoutGuide).offset(4)
  //
  // make.leading.equalTo(prev?.snp.trailing ?? (make.item as? UIView)?.superview ?? 0) 用这种写法，内部使用 make.item.superview，是相对的，不用写死
  // make.leading.equalTo(prev?.snp.trailing ?? nameLabel.superview ?? 0) 这里的写死的
}
// 一个内部使用 auto-layout 的视图，被 frame 布局，情况如何？
// class RedView: UIView {
//   override init(frame: CGRect) {
//     super.init(frame: frame)
//     // translatesAutoresizingMaskIntoConstraints = false
//     backgroundColor = .yellow
//     let lb = UILabel()
//     lb.text = "asdf"
//     addSubview(lb)
//     lb.snp.remakeConstraints { make in
//       make.edges.equalToSuperview().inset(UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
//     }
//   }
//   required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
// }
// 在 viewWillLayoutSubviews 设置 frame，能成功，且设置的 frame.size 优先级大于固有尺寸
//   控制台有约束冲突警告，查看视图层级时没有约束警告
//   经验证，控制台的约束冲突是因为创建视图用的是 RedView()，而不是 RedView(frame: xxx)
//   只要传正确的 frame，控制台就没有冲突警告了
//   那俩冲突说的是 width/height == 0，和 left/right 冲突了
//   因为左右边距是 10*2，所以，只要 RedView 的初始化宽度 <20 就会有警告
//   所以，可以在初始化时用 20*20 的 size，消除警告，后面在 viewWillLayoutSubviews 里再设置真正的尺寸
// translatesAutoresizingMaskIntoConstraints = false 以后，情况不一样了
//   不管初始化时传不传 frame，不管后面在 viewWillLayoutSubviews 设置什么尺寸，都没用，视图始终是固有尺寸
//   且位置在 (0,0) 错的，查看图层也说 position ambiguous
// 所以，就算 frame 包 auto-layout，本质也是把 frame 转化成 auto-layout 了，否则要出错



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
