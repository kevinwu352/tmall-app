//
//  NavigationController.swift
//  ModCommon
//
//  Created by Kevin Wu on 2022/1/1.
//

import UIKit

public class NavigationController: UINavigationController {

  public override func viewDidLoad() {
    super.viewDidLoad()
    delegate = self
    interactivePopGestureRecognizer?.delegate = self
  }

  deinit {
    delegate = nil
    interactivePopGestureRecognizer?.delegate = nil
  }


  var popGestureEnabled = true


  var pushing = false

  public override func pushViewController(_ viewController: UIViewController, animated: Bool) {
    pushing = true
    if viewControllers.count == 1 {
      viewController.hidesBottomBarWhenPushed = true
    }
    super.pushViewController(viewController, animated: animated)
  }

}

extension NavigationController: UINavigationControllerDelegate {
  public func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
    (navigationController as? NavigationController)?.pushing = false
  }
}

extension NavigationController: UIGestureRecognizerDelegate {
  public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
    if interactivePopGestureRecognizer != nil && popGestureEnabled {
      let popable = viewControllers.count > 1
      let popGestureEnabled = (viewControllers.last as? BaseViewController)?.popGestureEnabled ?? true
      return !pushing && popable && popGestureEnabled
    }
    return true
  }
}

//extension NavigationController: UIAdaptivePresentationControllerDelegate {
//  public func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
//    if modalPresentationStyle == .pageSheet {
//      presentationController.presentingViewController.invokeLifecycle(true)
//    }
//  }
//}
