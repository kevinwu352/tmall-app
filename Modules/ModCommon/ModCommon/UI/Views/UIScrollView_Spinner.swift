//
//  UIScrollView_Spinner.swift
//  ModCommon
//
//  Created by Kevin Wu on 2022/1/1.
//

import UIKit
import Combine
import MJRefresh

fileprivate var kHeadHandlerKey: UInt8 = 0
fileprivate var kHeadPublisherKey: UInt8 = 0

fileprivate class SpinnerView: UIView { }
fileprivate let kHeadImages: [[UIImage]] = {
  Theme.allCases
    .map { $0.code }
    .map { code in (1...30).map({ String(format: "/refresh/spinner_%02d_%@@%dx.png", $0, code, SCREEN_SCL) }) }
    .map { $0.compactMap({ UIImage(contentsOfFile: Bundle(for: SpinnerView.self).bundlePath.addedPathseg($0)) }) }
}()

public extension UIScrollView {

  var headHandler: VoidCb? {
    get { objc_getAssociatedObject(self, &kHeadHandlerKey) as? VoidCb }
    set { objc_setAssociatedObject(self, &kHeadHandlerKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC) }
  }

  var headPublisher: PassthroughSubject<Void,Never> {
    if let pub = objc_getAssociatedObject(self, &kHeadPublisherKey) as? PassthroughSubject<Void,Never> {
      return pub
    } else {
      let pub = PassthroughSubject<Void,Never>()
      objc_setAssociatedObject(self, &kHeadPublisherKey, pub, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
      return pub
    }
  }

  func headReset(_ show: Bool) {
    if show {
      let view: MJRefreshGifHeader
      if let header = mj_header as? MJRefreshGifHeader {
        view = header
      } else {
        view = MJRefreshGifHeader()
        mj_header = view
      }
      view.lastUpdatedTimeLabel?.isHidden = true
      view.stateLabel?.isHidden = true
      view.chg.theme("update") {
        $0.backgroundColor = .head_background
        let images = kHeadImages[THEME.rawValue]
        $0.setImages(images, duration: 1.5, for: .idle)
        $0.setImages(images, duration: 1.5, for: .pulling)
        $0.setImages(images, duration: 1.5, for: .refreshing)
      }
      view.mj_h = 54

      view.refreshingBlock = { [weak self] in
        guard let self = self else { return }
        self.headHandler?()
        (objc_getAssociatedObject(self, &kHeadPublisherKey) as? PassthroughSubject<Void,Never>)?.send()
      }
      view.endRefreshing()
    } else {
      if let header = mj_header {
        if header.isRefreshing {
          header.endRefreshing { [weak self] in self?.mj_header = nil }
        } else {
          mj_header = nil
        }
      }
    }
  }

  func headBeginRefreshing() {
    mj_header?.beginRefreshing() // will trigger handler
  }

  func headEndRefreshing() {
    mj_header?.endRefreshing()
  }
}


fileprivate var kFootHandlerKey: UInt8 = 0
fileprivate var kFootPublisherKey: UInt8 = 0

public extension UIScrollView {

  var footHandler: VoidCb? {
    get { objc_getAssociatedObject(self, &kFootHandlerKey) as? VoidCb }
    set { objc_setAssociatedObject(self, &kFootHandlerKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC) }
  }

  var footPublisher: PassthroughSubject<Void,Never> {
    if let pub = objc_getAssociatedObject(self, &kFootPublisherKey) as? PassthroughSubject<Void,Never> {
      return pub
    } else {
      let pub = PassthroughSubject<Void,Never>()
      objc_setAssociatedObject(self, &kFootPublisherKey, pub, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
      return pub
    }
  }

  func footReset(_ show: Bool, _ more: Bool) {
    if show {
      let view: MJRefreshAutoNormalFooter
      if let footer = mj_footer as? MJRefreshAutoNormalFooter {
        view = footer
      } else {
        view = MJRefreshAutoNormalFooter()
        mj_footer = view
      }
      view.chg.language("update") {
        $0.setTitle(R.string.com.refresh_foot_idle.cur, for: .idle)
        $0.setTitle(R.string.com.refresh_foot_refreshing.cur, for: .refreshing)
        $0.setTitle(R.string.com.refresh_foot_nomore.cur, for: .noMoreData)
      }
      view.chg.theme("update") {
        $0.backgroundColor = .foot_background
        $0.loadingView?.color = .foot_indicator
        $0.stateLabel?.font = .foot_title
        $0.stateLabel?.textColor = .foot_title
      }
      view.mj_h = 44

      view.refreshingBlock = { [weak self] in
        guard let self = self else { return }
        self.footHandler?()
        (objc_getAssociatedObject(self, &kFootPublisherKey) as? PassthroughSubject<Void,Never>)?.send()
      }
      if more {
        view.endRefreshing()
        view.resetNoMoreData()
      } else {
        view.endRefreshingWithNoMoreData()
      }
    } else {
      if let footer = mj_footer {
        if footer.isRefreshing {
          footer.endRefreshing { [weak self] in self?.mj_footer = nil }
        } else {
          mj_footer = nil
        }
      }
    }
  }
}


// [COLORS]
extension UIColor {
  static let head_background: UIColor = .clear
  static let foot_background: UIColor = .clear
  static var foot_indicator: UIColor { [UIColor.black, UIColor.white][THEME.rawValue] }
  static var foot_title: UIColor { [UIColor.black, UIColor.white][THEME.rawValue] }
}
// [FONTS]
extension UIFont {
  static let foot_title = UIFont.systemFont(ofSize: 14, weight: .regular)
}
