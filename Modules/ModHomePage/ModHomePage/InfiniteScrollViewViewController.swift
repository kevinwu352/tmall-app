//
//  InfiniteScrollViewViewController.swift
//  ModHomePage
//
//  Created by Kevin Wu on 5/24/26.
//

import UIKit

// UIScrollView 的 bounds 的 origin 是当前 offset 的点，size 等于窗口大小

class InfiniteScrollViewViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

      view.addSubview(pageView)

      pageView.frame = CGRect(x: 20, y: 200, width: 250, height: 200)

      let views = (0..<3).map {
        let ret = UILabel()
        ret.font = .boldSystemFont(ofSize: 24)
        ret.textColor = .red
        ret.text = "\($0)"
        ret.backgroundColor = .rand
        ret.frame = CGRect(x: $0 * 250, y: 0, width: 250, height: 200)
        ret.tag = $0
        return ret
      }

      pageView.config(views)
      pageView.autoscroll(time: 5)
      // pageView.stopAutoscrolling()
      // pageView.scrollToNext()
      pageView.indexHandler = { print($0) }

      // var list: [Int] = []
      // // list.move(fromOffsets: [0], toOffset: list.count)
      // list.move(fromOffsets: [list.count - 1], toOffset: 0)
      // print(list)
    }

  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesBegan(touches, with: event)
    print("frame:\(pageView.frame) bounds:\(pageView.bounds) content:\(pageView.contentSize) offset:\(pageView.contentOffset)")

    // pageView.stopScrolling()
    // navigationController?.popViewController(animated: true)
    // pageView.setContentOffset(pageView.contentOffset, animated: false)
    // pageView.pages.forEach {
    //   print("print, \($0.tag), \($0.center.x - 125)")
    // }
  }

  lazy var pageView: InfinitePageView = {
    let ret = InfinitePageView()
    ret.backgroundColor = .lightGray
    return ret
  }()

}

// 在外部先算好单个页面自己的尺寸就可以了，内部会用 UIView 包起来，且在页面内部居中定位
// pageView.config(views)
// pageView.autoscroll(time: 5)
// // pageView.stopAutoscrolling()
// // pageView.scrollToNext()
// pageView.indexHandler = { print($0) }
class InfinitePageView: UIScrollView, UIScrollViewDelegate {
  // deinit { print("[inf] deinit scroll") }

  func config(_ list: [UIView]) {
    // print("[inf] config")
    delegate = self
    showsHorizontalScrollIndicator = false
    showsVerticalScrollIndicator = false
    isPagingEnabled = true

    scrollWork = nil
    setContentOffset(.zero, animated: false)
    calcWork = nil

    pages.forEach { $0.removeFromSuperview() }
    let views = list.enumerated().map {
      let view = UIView()
      view.clipsToBounds = true
      view.tag = $0.offset
      view.frame = CGRect(x: CGFloat($0.offset) * frame.width, y: 0, width: frame.width, height: frame.height)
      view.addSubview($0.element)
      $0.element.center = CGPoint(x: frame.width / 2, y: frame.height / 2)
      return view
    }
    addSubviews(views)
    pages = views
    let count = pages.count > 1 ? CGFloat(max(pages.count * 4, 20)) : 1.0
    contentSize = CGSize(width: frame.width * count, height: frame.height)
    layoutIfNeeded()
  }
  var pages: [UIView] = []

  override func layoutSubviews() {
    super.layoutSubviews()
    // print("[inf] layout, \(pages.count) \(bounds.width)")
    guard pages.count > 1 && bounds.width > 10.0 else { return }
    recenterIfNeeded()
    movePageIfNeeded()
  }

  func recenterIfNeeded() {
    // 假设总共 5 页，那么整个空间是 20 页，初始时，将 0-4 页依次放入 10-14 页的空间内
    let fixedOffset = pinToPage(contentOffset.x)
    let centerOffsetX = contentSize.width / 2
    let distanceFromCenter = abs(contentOffset.x - centerOffsetX)
    if distanceFromCenter > (contentSize.width / 4) {
      contentOffset = CGPoint(x: centerOffsetX, y: contentOffset.y)
      pages.forEach {
        // print("[inf] recenter, \($0.tag), \($0.center.x - frame.width/2) -> \($0.center.x + (centerOffsetX - fixedOffset) - frame.width/2), \(centerOffsetX - fixedOffset)")
        $0.center.x += (centerOffsetX - fixedOffset)
      }
    }
  }

  func movePageIfNeeded() {
    var begin = pages.last?.tag
    while let last = pages.last, last.frame.maxX < bounds.maxX {
      if let first = pages.first {
        if first.tag == begin { break }
        let offset = last.frame.maxX + first.bounds.width / 2
        // print("[inf] =>>>>>, \(first.center.x - frame.width/2) -> \(offset - frame.width/2)")
        first.center.x = offset
        pages.move(fromOffsets: [0], toOffset: pages.count)
      }
    }
    begin = pages.first?.tag
    while let first = pages.first, first.frame.minX > bounds.minX {
      if let last = pages.last {
        if last.tag == begin { return }
        let offset = first.frame.minX - last.bounds.width / 2
        // print("[inf] <<<<<=, \(last.center.x - frame.width/2) -> \(offset - frame.width/2)")
        last.center.x = offset
        pages.move(fromOffsets: [pages.count - 1], toOffset: 0)
      }
    }
  }

  var scrollWork: DispatchWorkItem? {
    didSet { oldValue?.cancel() }
  }
  var interval: TimeInterval = 0
  func autoscroll(time: Double = 3) {
    guard pages.count > 1 else { return }
    interval = time
    scrollWork = DispatchWorkItem { [weak self] in self?.scrollToNext() }
    DispatchQueue.main.asyncAfter(deadline: .now() + interval, execute: scrollWork!)
  }
  func stopAutoscrolling() {
    scrollWork = nil
  }
  func scrollToNext() {
    guard pages.count > 1 else { return }
    setContentOffset(CGPoint(x: pinToPage(contentOffset.x + frame.width), y: contentOffset.y), animated: true)
    if interval > 0 {
      scrollWork = DispatchWorkItem { [weak self] in self?.scrollToNext() }
      DispatchQueue.main.asyncAfter(deadline: .now() + interval, execute: scrollWork!)
    }
  }

  func pinToPage(_ offset: CGFloat) -> CGFloat {
    guard frame.width > 10.0 else { return offset }
    let page = offset / frame.width
    let ratio = Int(page * 100) % 100
    let fixed = ratio >= 50 ? ceil(page) : floor(page)
    // print("[inf] page:\(page), ratio:\(ratio), fixed:\(fixed), offset:\(fixed * frame.width)")
    return fixed * frame.width
  }

  // func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
  //   // print("[inf] begin-dragging")
  //   scrollWork = nil
  //   setContentOffset(contentOffset, animated: false)
  // }
  // func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
  //   // print("[inf] end-dragging:\(decelerate)")
  //   guard !decelerate else { return }
  //   didEndScroll()
  // }
  // func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
  //   // print("[inf] end-decelerating")
  //   didEndScroll()
  // }
  // func didEndScroll() {
  //   setContentOffset(CGPoint(x: pinToPage(contentOffset.x), y: contentOffset.y), animated: true)
  //   if interval > 0 {
  //     autoscroll(time: interval)
  //   }
  // }

  var indexHandler: ((Int) -> Void)? {
    didSet { calcCurrentIndex() }
  }
  var calcWork: DispatchWorkItem? {
    didSet { oldValue?.cancel() }
  }
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    // print("[inf] did-scroll")
    calcWork = DispatchWorkItem { [weak self] in self?.calcCurrentIndex() }
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: calcWork!)
  }
  func calcCurrentIndex() {
    let list = pages
      .filter { bounds.intersects($0.frame) }
      .map { ($0.tag, [bounds.minX, bounds.maxX, $0.frame.minX, $0.frame.maxX].sorted()) }
      .sorted { $0.1[2] - $0.1[1] < $1.1[2] - $1.1[1] }
    if let index = list.last?.0 {
      // print("[inf] calc:\(index)")
      indexHandler?(index)
    } else {
      indexHandler?(0)
    }
  }

}
