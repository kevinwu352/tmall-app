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
      let topNotShown = viewControllers.count > 1
      let popGestureEnabled = (viewControllers.last as? BaseViewController)?.popGestureEnabled ?? true
      return !pushing && topNotShown && popGestureEnabled
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


// 实现自定义的 push/pop 转场
// extension NavigationController: UINavigationControllerDelegate {
//   public func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> (any UIViewControllerAnimatedTransitioning)? {
//     MyAnimator(push: operation == .push)
//   }
// }
//
// class MyAnimator: NSObject, UIViewControllerAnimatedTransitioning {
//   init(push: Bool) {
//     pushing = push
//   }
//   let pushing: Bool
//
//   func transitionDuration(using transitionContext: (any UIViewControllerContextTransitioning)?) -> TimeInterval {
//     5
//   }
//
//   func animateTransition(using transitionContext: any UIViewControllerContextTransitioning) {
//     let containerView = transitionContext.containerView
//
//     let fromViewController = transitionContext.viewController(forKey: .from)
//     let toViewController = transitionContext.viewController(forKey: .to)
//     var fromView = fromViewController?.view
//     var toView = toViewController?.view
//
//     if pushing {
//       toView?.frame = CGRectMake(UIScreen.main.bounds.width, 0, fromView!.frame.width, fromView!.frame.height)
//     } else {
//       toView?.frame = CGRectMake(-UIScreen.main.bounds.width, 0, fromView!.frame.width, fromView!.frame.height)
//     }
//     containerView.addSubview(toView!)
//
//     let duration = transitionDuration(using: transitionContext)
//     UIView.animate(withDuration: duration, delay: 0, options: .curveLinear) {
//       let frame = transitionContext.finalFrame(for: toViewController!)
//       toView?.frame = frame
//     } completion: { finished in
//       let cancelled = transitionContext.transitionWasCancelled
//       transitionContext.completeTransition(!cancelled)
//     }
//   }
// }
