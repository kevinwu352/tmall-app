//
//  CollectionViewController.swift
//  ModHomePage
//
//  Created by Kevin Wu on 2/19/26.
//

import UIKit
import ModCommon

class CollectionViewController: UIViewController, UICollectionViewDataSource {
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .lightGray
    view.addSubview(collectionView)
  }
  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    collectionView.frame = view.bounds
  }

  lazy var collectionView: UICollectionView = {
    let items = 3.0
    let hor_margin = 32.0
    let ver_margin = 20.0
    let item_height = 140.0
    let ver_spacing = 24.0

    let item_width = 96.0
    let hor_spacing = floor( (SCREEN_WID - hor_margin*2 - item_width*items) / (items-1) )
    //let hor_spacing = 50.0
    //let item_width = floor( (kScreenWidth - hor_margin*2 - hor_spacing*(items-1)) / items )


    let layout = UICollectionViewFlowLayout()
    layout.scrollDirection = .vertical
    layout.sectionInset = UIEdgeInsets(top: ver_margin, left: hor_margin, bottom: ver_margin, right: hor_margin)
    layout.itemSize = CGSize(width: item_width, height: item_height)
    //layout.estimatedItemSize
    layout.minimumInteritemSpacing = hor_spacing
    layout.minimumLineSpacing = ver_spacing
    layout.headerReferenceSize = CGSize(width: SCREEN_WID, height: 100)
    //layout.footerReferenceSize
    //layout.sectionHeadersPinToVisibleBounds
    //layout.sectionFootersPinToVisibleBounds


    let lll = ChatCollectionViewLayout()

    let ret = UICollectionView(frame: .zero, collectionViewLayout: lll)
    ret.dataSource = self
    // ret.delegate = self
    ret.register(CollectionCell.self, forCellWithReuseIdentifier: "cell")
    ret.register(CollectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
    ret.backgroundColor = .clear

    return ret
  }()

  func numberOfSections(in collectionView: UICollectionView) -> Int {
    print(#function)
    return 1
  }

  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    print(#function)
    return 40
  }

  // func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
  //   UIEdgeInsets(top: 20, left: 10, bottom: 20, right: 10)
  // }
  // func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
  //   10
  // }
  // func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
  //   // floor( (SCREEN_WID - 32*2 - 96 * 3) / (3 - 1) )
  //   10
  // }
  // func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
  //   if indexPath.row == 1 {
  //     return CGSize(width: (SCREEN_WID - 30) / 2, height: 150)
  //   } else {
  //     return CGSize(width: (SCREEN_WID - 30) / 2, height: 140)
  //   }
  // }
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionCell
    cell.label.text = "\(indexPath.row)"
    return cell
  }

  func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    print(kind)
    if kind == UICollectionView.elementKindSectionHeader {
      let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath) as! CollectionHeaderView
      return header
    }
    return UICollectionReusableView()
  }
}

class CollectionCell: BaseCollectionViewCell {
  override func setup() {
    contentView.backgroundColor = .rand
    contentView.addSubview(label)
  }
  override func layoutSubviews() {
    super.layoutSubviews()
    label.sizeToFit()
    label.frame = contentView.bounds
    // label.center = center
  }
  lazy var label: UILabel = {
    let ret = UILabel()
    return ret
  }()
}

class CollectionHeaderView: UICollectionReusableView {
  override init(frame: CGRect) {
    super.init(frame: frame)
    backgroundColor = .red
  }
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

class ChatCollectionViewLayout: UICollectionViewLayout {
  var cache: [UICollectionViewLayoutAttributes] = []

  override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
    print(#function)
    return false
  }

  override func prepare() {
    print(#function)
    cache = []

    let attr = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, with: IndexPath(item: 0, section: 0))
    attr.frame = CGRect(x: 0, y: 0, width: SCREEN_WID, height: 100)
    cache.append(attr)

    let count = collectionView?.numberOfItems(inSection: 0) ?? 0
    for i in 0..<count {
      let ip = IndexPath(item: i, section: 0)
      let attrs = UICollectionViewLayoutAttributes(forCellWith: ip)
      attrs.frame = CGRect(x: Double(i % 2) * (SCREEN_WID/2),
                         y: Double(i / 2) * 50 + 100,
                         width: SCREEN_WID, height: 50)
      cache.append(attrs)
    }
  }
  // 这方法也没调用，文档说是 insert/delete 之前通知
  // 我估计，如果没有添加删除，不用这方法
  override func prepare(forCollectionViewUpdates updateItems: [UICollectionViewUpdateItem]) {
    print(#function)
  }

  // 这里会被主动调用
  override var collectionViewContentSize: CGSize {
    print(#function)
    return CGSize(width: SCREEN_WID, height: 1100)
  }

  // 这里会被主动调用
  override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
    let list = cache.filter { $0.frame.intersects(rect) }
    print("\(#function)")
    return list
  }
  // 感觉这东西不是必须的，不是主动调用这方法
  // 初始的布局信息不是因为主动调用这方法并从这里创建再存到 cache 里，而是在 prepare 里创建，这里返回 cache 里的
  override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
    print(#function)
    return indexPath.row >= 0 && indexPath.row < cache.count ? cache[indexPath.row] : nil
  }
}

// 初始时
// prepare()
//   numberOfSections(in:)
//   collectionView(_:numberOfItemsInSection:)
// collectionViewContentSize
// layoutAttributesForElements(in:)
// collectionViewContentSize
//
// 滑动以后，打印很多次下面这几行
// shouldInvalidateLayout(forBoundsChange:)
// prepare()
// collectionViewContentSize
// layoutAttributesForElements(in:)
// collectionViewContentSize
// 如果 shouldInvalidateLayout 返回 false 则不会调这些
//   我感觉，滑动时候会改变布局时才返回 true，比如 CoverFlow 滑动时，前一个视图的布局会变化
//   而如果只是纯粹的瀑布流布局，其实布局在滑动过程中是不变的
// 且 layoutAttributesForItem(at:) 不会被调用
