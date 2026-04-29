//
//  HugCompressView.swift
//  ModHomePage
//
//  Created by Kevin Wu on 4/29/26.
//

import UIKit
import ModCommon

class HugCompressView: BaseView {
  override func setup() {
    super.setup()
    backgroundColor = .lightGray
    addSubview(lb)
  }
  override func layoutViews() {
    super.layoutViews()
    lb.snp.remakeConstraints { make in
      make.edges.equalToSuperview().inset(UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
    }
  }
  // override var intrinsicContentSize: CGSize {
  //   CGSize(width: 300, height: 500)
  // }
  lazy var lb: UILabel = {
    let ret = UILabel()
    ret.backgroundColor = .yellow
    ret.font = .systemFont(ofSize: 14)
    ret.textColor = .black
    ret.numberOfLines = 0

    // UILabel/UIImageView 抗拉优先级是 251
    // UIButton/UIView 抗拉优先级是 250

    // 当我内容多时，我的 抗压compress(750) 优先级对抗父的 抗拉hug(250) 优先级，所以，
    // 0)默认情况750肯定是我占优势，我把父撑大
    // 1)当我250时，等于父，保持我的 intrinsic-size，我把父撑大
    // 2)当我249时，小于父，保持父的 intrinsic-size，我被压小
    // ret.setContentCompressionResistancePriority(UILayoutPriority(249), for: .horizontal)
    // ret.text = "The first example where this can be seen in action, and perhaps the one most viewed by users, is that of notification banners."
    //
    // 当我内容少时，我的 抗拉hug(250) 优先级对抗父的 抗压compress(750) 优先级，所以，
    // 0)默认情况250肯定是父占优势，我被拉大
    // 1)当我749时，小于父，保持父的 intrinsic-size，我被拉大
    // 2)当我750时，等于父，保持我的 intrinsic-size，我把父拉小
    // ret.setContentHuggingPriority(UILayoutPriority(750), for: .horizontal)
    ret.text = "notification banners"

    // 当父要求尽量小的时候，哪个优先级能撑起父的尺寸？
    // 1)如果把此视图放到 vc.view.center，就算 lb 的抗压优先级是 1，也能撑起父的尺寸，0 不行
    // ret.setContentCompressionResistancePriority(UILayoutPriority(1), for: .horizontal)
    // ret.setContentCompressionResistancePriority(UILayoutPriority(1), for: .vertical)
    // 2)如果把此视图放到 vc.view.stack 里，stack 要求视图尽量小，优先级设 >=50 才能撑起父的尺寸
    // ret.setContentCompressionResistancePriority(UILayoutPriority(50), for: .horizontal)
    // ret.setContentCompressionResistancePriority(UILayoutPriority(50), for: .vertical)

    // 所以，一个子视图，既要撑起父，又不过分影响父，空间太多时拉大自己，空间不够时压缩自己
    // 它的最佳优先级是 150，因为 50 < 150 < 250

    ret.setContentCompressionResistancePriority(UILayoutPriority(150), for: .horizontal)
    ret.setContentCompressionResistancePriority(UILayoutPriority(150), for: .vertical)
    ret.setContentHuggingPriority(UILayoutPriority(150), for: .horizontal)
    ret.setContentHuggingPriority(UILayoutPriority(150), for: .vertical)

    return ret
  }()
}
