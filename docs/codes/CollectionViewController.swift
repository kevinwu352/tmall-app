//
//  CollectionViewController.swift
//  ModHomePage
//
//  Created by Kevin Wu on 2024/01/10.
//

import UIKit
import ModCommon

class CollectionViewController: BaseViewController {

    override func setup() {
        super.setup()
        view.backgroundColor = .lightGray
        view.addSubview(collectionView)
    }
    override func layoutViews() {
        super.layoutViews()
        collectionView.snp.remakeConstraints { make in
            make.pin_head(navbar, 20, view, 20)
            make.pin_waist(20)
            make.height.equalTo(300)
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)

        entries = ["BTC", "ETH/USDT", "BTC/USDT", "BNB", "SAND/USDT", "GMT/USDT"]
        collectionView.reloadData()
        collectionView.layoutIfNeeded()
        print(collectionView.contentSize)

        DispatchQueue.main.delay(2.0) {
            print(self.collectionView.contentSize)
        }
    }

    var entries: [String] = []

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


        let layout = UICollectionViewLeftAlignedLayout()
        layout.scrollDirection = .vertical
//        layout.sectionInset = UIEdgeInsets(top: ver_margin, left: hor_margin, bottom: ver_margin, right: hor_margin)
//        layout.itemSize = CGSize(width: item_width, height: item_height)
        //layout.estimatedItemSize
        layout.minimumInteritemSpacing = 12
        layout.minimumLineSpacing = 12
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        //layout.headerReferenceSize
        //layout.footerReferenceSize
        //layout.sectionHeadersPinToVisibleBounds
        //layout.sectionFootersPinToVisibleBounds

        let ret = UICollectionView(frame: .zero, collectionViewLayout: layout)
        ret.backgroundColor = .darkGray
        ret.dataSource = self
        ret.registerCell(CollectionCell.self)
        ret.backgroundColor = .clear

        return ret
    }()
}

extension CollectionViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        entries.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueCell(CollectionCell.self, indexPath)
        cell.textLabel.text = entries.at(indexPath.row)
        return cell
    }
}

class CollectionCell: BaseCollectionViewCell, Reusable {
    override func setup() {
        super.setup()
        contentView.addSubview(frameView)
        contentView.addSubview(textLabel)
    }
    override func layoutViews() {
        super.layoutViews()
        frameView.snp.remakeConstraints { make in
            make.edges.equalToSuperview()
        }
        textLabel.snp.remakeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 4, left: 12, bottom: 4, right: 12))
            make.height.equalTo(18)
        }
    }
    lazy var frameView: UIView = {
        let ret = UIView()
        ret.backgroundColor = .red
        ret.layer.cornerRadius = 12
        return ret
    }()
    lazy var textLabel: UILabel = {
        let ret = UILabel.fromStyle(font: UIFont.systemFont(ofSize: 12),
                                    color: .black,
                                    alignment: .center,
                                    breakmode: .byWordWrapping)
        return ret
    }()
}
