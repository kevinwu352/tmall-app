//
//  TransitViewController.swift
//  ModHomePage
//
//  Created by Kevin Wu on 4/10/26.
//

import UIKit
import Combine

// 能实现自定义的 present/dismiss 转场
// 也能自定义 push/pop 转场

// UIViewController.transitionCoordinator is UIViewControllerTransitionCoordinator
//   UIViewControllerTransitionCoordinator : UIViewControllerTransitionCoordinatorContext

// UIViewControllerTransitioningDelegate 协议内部的方法会返回下面两种类型的转场
//
// UIViewControllerAnimatedTransitioning
// UIViewControllerInteractiveTransitioning
//
// 上面两个协议内部的方法会用此类型的参数，里面包含做转场动画需要的信息，不要自己实现，系统会传一个过来
// UIViewControllerContextTransitioning


class HomeViewController: UIViewController, UIViewControllerTransitioningDelegate {
  lazy var bag = Set<AnyCancellable>()

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white

  }

  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesEnded(touches, with: event)
    print("push 1, \(transitionCoordinator)")
    // navigationController?.pushViewController(TestViewController(), animated: true)


    let vc = TestViewController()

    // vc.transitioningDelegate = self
    // vc.modalPresentationStyle = .fullScreen
    // present(vc, animated: true)

    navigationController?.pushViewController(vc, animated: true)
    // DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
    //   print("begin pop")
    //   self.popToSelf(true) {
    //     print("home pop done")
    //   }
    // }

    // 事实证明，当前vc 和 被present的vc 的 transitionCoordinator 是相同的
    //
    // transitionCoordinator.animate 方法里的两个 context 参数也是 transitionCoordinator 本身
    //
    // 如果上面 present 时传 false，转场瞬间完成，且 isAnimated 是 false
    //
    // present 时，不管是不是自定义动画，transitionCoordinator 上都拿不到动画时间
    //
    //
    // push 时设置 transitioningDelegate 不会起作用，要在 UINavigationControllerDelegate 里返回 UIViewControllerAnimatedTransitioning
    // push 时，不管有没有自定义转场，能拿到动画时间，且能拿到 0.35 和 5 这样的准确时间


    // print("push 21, \(transitionCoordinator) \(vc.transitionCoordinator)")
    // print("push 22, isAnimated:\(transitionCoordinator?.isAnimated) isCancelled:\(transitionCoordinator?.isCancelled) style:\(transitionCoordinator?.presentationStyle) duration:\(transitionCoordinator?.transitionDuration)")

    // if let tc = transitionCoordinator {
    //   print("push 3, \(tc) isAnimated:\(tc.isAnimated) isCancelled:\(tc.isCancelled)")
    //   tc.animate { context in
    //     print("push 41, \(context) isAnimated:\(context.isAnimated) isCancelled:\(context.isCancelled)")
    //   } completion: { context in
    //     print("push 42, \(context) isAnimated:\(context.isAnimated) isCancelled:\(context.isCancelled)")
    //   }
    //   // tc.animate(alongsideTransition: nil) { context in
    //   //   print("push 4, \(context) percentComplete:\(context.percentComplete) isAnimated:\(context.isAnimated) isCancelled:\(context.isCancelled)")
    //   // }
    // } else {
    //   print("push 3, nil")
    // }
  }

  func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> (any UIViewControllerAnimatedTransitioning)? {
    MyAnimator()
  }
  // func animationController(forDismissed dismissed: UIViewController) -> (any UIViewControllerAnimatedTransitioning)? {
  //   CrossDissolveAnimator()
  // }

}

class MyAnimator: NSObject, UIViewControllerAnimatedTransitioning {
  func transitionDuration(using transitionContext: (any UIViewControllerContextTransitioning)?) -> TimeInterval {
    5
  }

  func animateTransition(using transitionContext: any UIViewControllerContextTransitioning) {
    let containerView = transitionContext.containerView

    // 需要关注一下from/to和presented/presenting的关系
    // For a Presentation:
    //      fromView = The presenting view.
    //      toView   = The presented view.
    // For a Dismissal:
    //      fromView = The presented view.
    //      toView   = The presenting view.
    let fromViewController = transitionContext.viewController(forKey: .from)
    let toViewController = transitionContext.viewController(forKey: .to)
    var fromView = fromViewController?.view
    var toView = toViewController?.view
    // print("111 \(fromView)")
    // print("222 \(toView)")

    // iOS8引入了viewForKey方法，尽可能使用这个方法而不是直接访问controller的view属性
    // 比如在form sheet样式中，我们为presentedViewController的view添加阴影或其他decoration，animator会对整个decoration view
    // 添加动画效果，而此时presentedViewController的view只是decoration view的一个子视图
    // fromView = transitionContext.view(forKey: .from)
    // toView = transitionContext.view(forKey: .to)
    // print("333 \(fromView)")
    // print("444 \(toView)")

    toView?.frame = CGRectMake(fromView!.frame.origin.x, fromView!.frame.maxY / 2, fromView!.frame.width, fromView!.frame.height)
    containerView.addSubview(toView!)

    let duration = transitionDuration(using: transitionContext)
    // 动画结束后一定要调用 completeTransition 方法
    UIView.animate(withDuration: duration, delay: 0, options: .curveLinear) {
      let frame = transitionContext.finalFrame(for: toViewController!)
      toView?.frame = frame
    } completion: { finished in
      let cancelled = transitionContext.transitionWasCancelled
      transitionContext.completeTransition(!cancelled)
    }
  }
}
