//
//  BaseCollectionViewCell.swift
//  ModCommon
//
//  Created by Kevin Wu on 2022/1/1.
//

import UIKit
import Combine

/*
lazy var collectionView: UICollectionView = {
    let items = 3.0
    let hor_margin = 32.0
    let ver_margin = 20.0
    let item_height = 140.0
    let ver_spacing = 24.0

    let item_width = 96.0
    let hor_spacing = floor( (kScreenWidth - hor_margin*2 - item_width*items) / (items-1) )
    //let hor_spacing = 50.0
    //let item_width = floor( (kScreenWidth - hor_margin*2 - hor_spacing*(items-1)) / items )


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
    ret.register(XXX.self, forCellWithReuseIdentifier: "cell")
    ret.backgroundColor = .clear

    return ret
}()
*/
/*
layout.headerReferenceSize = CGSize(width: xxx, height: xxx)
ret.register(XXXHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    if kind == UICollectionView.elementKindSectionHeader {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath) as! XXXHeaderView
        header...
        return header
    }
    fatalError("invalid kind")
}
*/

open class BaseCollectionViewCell: UICollectionViewCell, Combinable {

  public lazy var cancellables = Set<AnyCancellable>()

  open override class var requiresConstraintBasedLayout: Bool { true }

  public required init?(coder: NSCoder) {
    super.init(coder: coder)
  }
  open override func awakeFromNib() {
    super.awakeFromNib()
    setup()
    layoutViews()
    bindEvents()
    loadData()
    initialized = true
    reload()
  }
  public override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
    layoutViews()
    bindEvents()
    loadData()
    initialized = true
    reload()
  }
  open override func updateConstraints() {
    layoutViews()
    super.updateConstraints()
  }

  open func setup() {
  }
  open func layoutViews() {
  }
  open func bindEvents() {
  }
  open func loadData() {
  }

  public func setNeedsReload() {
    setNeeds(#selector(reload))
  }
  @objc open func reload() {
  }
  public var initialized = false

}
