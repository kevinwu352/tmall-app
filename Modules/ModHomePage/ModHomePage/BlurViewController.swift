//
//  BlurViewController.swift
//  ModHomePage
//
//  Created by Kevin Wu on 2024/07/19.
//

import UIKit
import ModCommon

/*
 // 文字
 let label: UILabel = UILabel()
 label.translatesAutoresizingMaskIntoConstraints = false
 label.text = "Vibrancy Effect"
 label.font = UIFont(name: "HelveticaNeue-Bold", size: 30)
 label.textAlignment = .center
 label.textColor = .white
 label.sizeToFit()
 //背景图
 let bgView: UIImageView = UIImageView(image: Res.img.hill.cur)
 bgView.frame = view.bounds
 view.addSubview(bgView)


 //模糊效果
 let blurEffect: UIBlurEffect = UIBlurEffect(style: .light)
 let blurView: UIVisualEffectView = UIVisualEffectView(effect: blurEffect)
 blurView.frame = CGRectMake(50.0, 50.0, view.frame.width - 100.0, 200.0)
 view.addSubview(blurView)

 let vibrancyView: UIVisualEffectView = UIVisualEffectView(effect: UIVibrancyEffect(blurEffect: blurEffect))
 blurView.contentView.addSubview(vibrancyView)
 vibrancyView.translatesAutoresizingMaskIntoConstraints = false
 //    vibrancyView.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
 NSLayoutConstraint.activate([
 vibrancyView.heightAnchor.constraint(equalTo: blurView.heightAnchor),
 vibrancyView.widthAnchor.constraint(equalTo: blurView.widthAnchor),
 vibrancyView.centerXAnchor.constraint(equalTo: blurView.centerXAnchor),
 vibrancyView.centerYAnchor.constraint(equalTo: blurView.centerYAnchor),
 ])

 vibrancyView.contentView.addSubview(label)
 label.translatesAutoresizingMaskIntoConstraints = false
 NSLayoutConstraint.activate([
 label.centerXAnchor.constraint(equalTo: vibrancyView.centerXAnchor),
 label.centerYAnchor.constraint(equalTo: vibrancyView.centerYAnchor),
 ])
*/

class BlurViewController: BaseViewController, UICollectionViewDataSource {

  override func setup() {
    super.setup()
    view.addSubview(collectionView)
  }
  override func layoutViews() {
    super.layoutViews()
    collectionView.snp.remakeConstraints { make in
      make.leading.trailing.bottom.equalToSuperview()
      make.pin_top(navbar, 0)
    }
  }

  lazy var styles: [UIBlurEffect.Style] = [
    .extraLight,
    .light,
    .dark,
    .regular,
    .prominent,

    .systemUltraThinMaterial,
    .systemThinMaterial,
    .systemMaterial,
    .systemThickMaterial,
    .systemChromeMaterial,

    .systemUltraThinMaterialLight,
    .systemThinMaterialLight,
    .systemMaterialLight,
    .systemThickMaterialLight,
    .systemChromeMaterialLight,

    .systemUltraThinMaterialDark,
    .systemThinMaterialDark,
    .systemMaterialDark,
    .systemThickMaterialDark,
    .systemChromeMaterialDark,
  ]
  lazy var names: [UIBlurEffect.Style:String] = [
    .extraLight: "extra Light",
    .light: "light",
    .dark: "dark",
    .regular: "regular",
    .prominent: "prominent",

    .systemUltraThinMaterial: "system Ultra Thin Material",
    .systemThinMaterial: "system Thin Material",
    .systemMaterial: "system Material",
    .systemThickMaterial: "system Thick Material",
    .systemChromeMaterial: "system Chrome Material",

    .systemUltraThinMaterialLight: "system Ultra Thin Material Light",
    .systemThinMaterialLight: "system Thin Material Light",
    .systemMaterialLight: "system Material Light",
    .systemThickMaterialLight: "system Thick Material Light",
    .systemChromeMaterialLight: "system Chrome Material Light",

    .systemUltraThinMaterialDark: "system Ultra Thin Material Dark",
    .systemThinMaterialDark: "system Thin Material Dark",
    .systemMaterialDark: "system Material Dark",
    .systemThickMaterialDark: "system Thick Material Dark",
    .systemChromeMaterialDark: "system Chrome Material Dark",
  ]

  lazy var collectionView: UICollectionView = {
    let items = 1.0
    let hor_margin = 20.0
    let ver_margin = 20.0
    let ver_spacing = 10.0
    let hor_spacing = 10.0

    let item_width = (SCREEN_WID - hor_margin * 2 - hor_spacing * (items-1)) / items
    let item_height = item_width / 2.0


    let layout = UICollectionViewFlowLayout()
    layout.scrollDirection = .vertical
    layout.sectionInset = UIEdgeInsets(top: ver_margin, left: hor_margin, bottom: ver_margin, right: hor_margin)
    layout.itemSize = CGSize(width: item_width, height: item_height)
    //layout.estimatedItemSize
    layout.minimumInteritemSpacing = hor_spacing
    layout.minimumLineSpacing = ver_spacing
    //layout.headerReferenceSize
    //layout.footerReferenceSize
    //layout.sectionHeadersPinToVisibleBounds
    //layout.sectionFootersPinToVisibleBounds

    let ret = UICollectionView(frame: .zero, collectionViewLayout: layout)
    ret.dataSource = self
    ret.register(EntryCell.self, forCellWithReuseIdentifier: "cell")
    ret.backgroundColor = .clear

    return ret
  }()

  func numberOfSections(in collectionView: UICollectionView) -> Int {
    1
  }
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    styles.count
  }
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! EntryCell

    cell.style = styles[indexPath.row]
    cell.label.text = names[styles[indexPath.row]]

    return cell
  }


  class EntryCell: BaseCollectionViewCell {
    override func setup() {
      super.setup()
      contentView.addSubview(imageView)
      contentView.addSubview(label)
    }
    override func layoutViews() {
      super.layoutViews()
      imageView.snp.remakeConstraints { make in
        make.edges.equalToSuperview()
      }
      label.snp.remakeConstraints { make in
        make.pin_waist(0)
        make.centerY.equalToSuperview()
      }
    }
    var style: UIBlurEffect.Style? {
      didSet {
        guard let style = style else { return }
        let effect: UIBlurEffect = UIBlurEffect(style: style)
        let view: UIVisualEffectView = UIVisualEffectView(effect: effect)
        contentView.insertSubview(view, belowSubview: label)
        view.snp.remakeConstraints { make in
          make.leading.top.bottom.equalToSuperview()
          make.width.equalToSuperview().multipliedBy(0.5)
        }

      }
    }
    lazy var imageView: UIImageView = {
      let ret = UIImageView(image: Res.img.hill.cur)
      return ret
    }()
    lazy var label: UILabel = {
      let ret = UILabel()
      ret.font = .systemFont(ofSize: 16)
      ret.textColor = .blue
      ret.textAlignment = .left
      ret.lineBreakMode = .byWordWrapping
      ret.numberOfLines = 0
      return ret
    }()
  }

}
