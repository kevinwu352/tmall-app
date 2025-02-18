//
//  Navigator.swift
//  ModCommon
//
//  Created by Kevin Wu on 2022/1/1.
//

import UIKit

public struct Navigator {

  public static var segs: [Route] = []


  public static func jump(_ link: String) {
    guard let routes = parseLink(link) else { return }
    jump(routes)
  }
  public static func jump(_ routes: [Route]) {
    guard routes.notEmpty else { return }
    guard let index = segs.firstIndex(of: routes[0]) else { return }

    guard let nc = nav(index) else { return }

    let vcs = parseRoutes(routes, nc.viewControllers)
    vcs.enumerated().forEach { $0.element.hidesBottomBarWhenPushed = $0.offset != 0 }

    tab()?.selectedIndex = index
    nc.setViewControllers(vcs, animated: true)
  }


  public static func append(_ link: String) {
    guard let routes = parseLink(link) else { return }
    append(routes)
  }
  public static func append(_ routes: [Route]) {
    guard routes.notEmpty else { return }

    guard let nc = nav(nil) else { return }

    let vcs = parseRoutes(routes, [])
    vcs.forEach { $0.hidesBottomBarWhenPushed = true }

    nc.setViewControllers(nc.viewControllers + vcs, animated: true)
  }


  public static func present(_ link: String, _ style: UIModalPresentationStyle?) {
    guard let routes = parseLink(link) else { return }
    present(routes, style)
  }
  public static func present(_ routes: [Route], _ style: UIModalPresentationStyle?) {
    guard routes.notEmpty else { return }

    let vcs = parseRoutes(routes, [])
    vcs.enumerated().forEach { $0.element.hidesBottomBarWhenPushed = $0.offset != 0 }

    present(vcs, style)
  }


  // 能解析出正确的路由
  public static func canOpen(_ link: String) -> Bool {
    parseLink(link) != nil
  }


  static func parseLink(_ link: String) -> [Route]? {
    var urls = link.split(separator: "/", omittingEmptySubsequences: false).map { $0.sup }
    // /a/b/c/ 删除前后空路由
    if let url = urls.first, url.isEmpty {
      urls.removeFirst()
    }
    if let url = urls.last, url.isEmpty {
      urls.removeLast()
    }
    if urls.isEmpty { return nil }

    var list: [Route] = []
    for url in urls {
      if let route = Route(url) {
        list.append(route)
      } else {
        return nil
      }
    }

    return list
  }

  static func parseRoutes(_ routes: [Route], _ vcs: [UIViewController]) -> [UIViewController] {
    routes.enumerated().compactMap { index, route in
      let vc: UIViewController?
      if let ctr = vcs.at(index), type(of: ctr) == route.type {
        vc = ctr
      } else {
        vc = route.type?.init()
      }
      if let param = route.param {
        (vc as? Routable)?.routeUpdate(param)
      }
      return vc
    }
  }


  static func tab() -> UITabBarController? {
    WINDOW?.rootViewController as? UITabBarController
  }
  static func nav(_ index: Int?) -> UINavigationController? {
    if let index = index {
      return tab()?.viewControllers?[index] as? UINavigationController
    } else {
      return tab()?.selectedViewController as? UINavigationController
    }
  }

}

public extension Navigator {

  static func present(_ vcs: [UIViewController], _ style: UIModalPresentationStyle?) {
    let nc = NavigationController()
    nc.isNavigationBarHidden = true
    nc.setViewControllers(vcs, animated: false)
    if let style = style { nc.modalPresentationStyle = style }
    //nc.presentationController?.delegate = nc
    //if style == .pageSheet { MODALTOP?.invokeLifecycle(false) }
    MODALTOP?.present(nc, animated: true, completion: nil)
  }

}
