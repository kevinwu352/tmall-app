//
//  UIViewController_Navigator.swift
//  ModCommon
//
//  Created by Kevin Wu on 2022/1/1.
//

import UIKit

// BOOL viewAppeared
// BOOL everAppeared

// navigationController
// 祖上的，就算 nav 包 tab，tab 里的 vc.nav 也能取到此
//
// tabBarController
// 祖上的，就算 tab 包 nav，nav 里的 vc.tab 也能取到此
//
// parent
// 直接父亲
//
// presentingViewController
// root present vc, root == vc.presenting == vc.sub.presenting == vc.sub.sub.presenting
// root present nav, root == nav.top.presenting == nav.top.sub.presenting == nav.top.sub.sub.presenting
// root present tab, root == tab.presenting == tab.vc.presenting == tab.vc.sub.presenting == tab.vc.sub.sub.presenting

// present 时，.fullScreen 样式会让父 vc 会收到 viewWillDisappear: 等事件，否则不算消失
// https://betterprogramming.pub/the-lifecycle-and-control-when-dismissing-a-modal-view-with-pagesheet-in-ios-13-4bbd1e3e1ec7
//
// .formSheet 样式时，下拖但不放手，会调用 viewWillDisappear-viewWillAppear-viewDidAppear

// receiver.dismiss(animated: true)
//   dismiss everything else to show receiver
//   dismiss receiver if no else

// nav 栈上有多个 vc，点击 tabbar 会直接回到 root，此时栈中间的 vc 不会调用 will/did appear，只有首尾的 vc 会调用
// 如果用 setViewControllers 直接从 [vc1] => [vc1, vc2, vc3]，中间的 vc2 也不会调用生命周期

// [vc1] 时，在 vc1 上调用三个 pop，都不会触发 nav.delegate.will/did show vc
// [vc1, vc2] 时，在 vc2 上调用三个 pop，只有 popTo(self) 不会触发
// [vc1, vc2, vc3] 时，在 vc3 上调用三个 pop，只有 popTo(self) 不会触发，popToRoot 不会触发 vc2 的生命周期函数

// 如果 popToViewController(not-in-stack-vc)，会调用 top-vc 的 will/did appear
// 如果 popToViewController(top-vc)，不会调用 will/did appear

// 在被 pop 的 vc.viewDidDisappear 里，navigationController 已经为空

public extension UIViewController {

  var navPrev: UIViewController? {
    if let i = navigationController?.viewControllers.firstIndex(of: self),
       let vc = navigationController?.viewControllers.at(i - 1)
    {
      return vc
    }
    return nil
  }
  var navNext: UIViewController? {
    if let i = navigationController?.viewControllers.firstIndex(of: self),
       let vc = navigationController?.viewControllers.at(i + 1)
    {
      return vc
    }
    return nil
  }

  var canPopSelf: Bool {
    navPrev != nil
  }
  func popSelf(_ animated: Bool, _ completion: VoidCb?) {
    if let prev = navPrev {
      navigationController?.popToViewController(prev, animated: animated)
      masy(animated ? 0.5 : 0.2, completion)
    } else {
      masy(0.2, completion)
    }
  }
  func popToSelf(_ animated: Bool, _ completion: VoidCb?) {
    if navNext != nil {
      navigationController?.popToViewController(self, animated: animated)
      masy(animated ? 0.5 : 0.2, completion)
    } else {
      masy(0.2, completion)
    }
  }


  var canDismissSelf: Bool {
    presentingViewController != nil
  }
  func dismissSelf(_ animated: Bool, _ completion: VoidCb?) {
    if let prev = presentingViewController {
      prev.dismiss(animated: animated, completion: completion)
      //if prev.presentedViewController?.modalPresentationStyle == .pageSheet { prev.invokeLifecycle(true) }
    } else {
      masy(0.2, completion)
    }
  }
  func dismissToSelf(_ animated: Bool, _ completion: VoidCb?) {
    if let ancestor = ancestor, ancestor.presentedViewController != nil {
      ancestor.dismiss(animated: animated, completion: completion)
      //if next.modalPresentationStyle == .pageSheet { outmost.invokeLifecycle(true) }
    } else {
      masy(0.2, completion)
    }
  }


  func backSelf(_ animated: Bool, _ completion: VoidCb?) {
    if navPrev != nil {
      popSelf(animated, completion)
    } else {
      dismissSelf(animated, completion)
    }
  }


//  func invokeLifecycle(_ appearing: Bool) {
//    beginAppearanceTransition(appearing, animated: true)
//    endAppearanceTransition()
//  }
}

public extension UINavigationController {
  func pop(_ count: Int, _ animated: Bool) {
    guard count >= 1 else { return }
    guard viewControllers.count >= 2 else { return }
    let total = viewControllers.count
    if count == 1 {
      popViewController(animated: animated)
    } else {
      if count >= total-1 {
        popToRootViewController(animated: animated)
      } else {
        popToViewController(viewControllers[total-count-1], animated: animated)
      }
    }
  }
}
