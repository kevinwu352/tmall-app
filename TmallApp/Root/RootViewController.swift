//
//  RootViewController.swift
//  TmallApp
//
//  Created by Kevin Wu on 2022/1/1.
//

import UIKit
import ModCommon

class RootViewController: UITabBarController {

  override func viewDidLoad() {
    super.viewDidLoad()
    view.chg.backgroundColor(.view_bg)

    reloadSegs()
    configChange()
  }

  var segs: [Route:UIViewController] = [:]

  func reloadSegs() {
    segs = [:]
    var vcs: [UIViewController] = []
    for route in Navigator.segs {
      let item = UITabBarItem(title: title(route), image: image(route), selectedImage: selectedImage(route))
      item.setTitleTextAttributes([.font: UIFont.tab_title, .foregroundColor: UIColor.tab_title_n as Any], for: .normal)
      item.setTitleTextAttributes([.font: UIFont.tab_title, .foregroundColor: UIColor.tab_title_h as Any], for: .selected)

      let root = route.type?.init() ?? UIViewController()
      let nc = NavigationController(rootViewController: root)
      nc.isNavigationBarHidden = true
      nc.tabBarItem = item

      vcs.append(nc)
      segs[route] = nc
    }
    setViewControllers(vcs, animated: false)
  }

  func title(_ route: Route) -> String? {
    switch route {
    case .HomePage: return R.string.com.homepage.cur
    case .HuaSuan: return R.string.com.huasuan.cur
    case .ShopCar: return R.string.com.shopcar.cur
    case .UserCenter: return R.string.com.usercenter.cur
    default: fatalError("unknown tab page, fuck you")
    }
  }
  func image(_ route: Route) -> UIImage? {
    switch route {
    case .HomePage: return R.image.tabbar.icon_home_n.cur?.original
    case .HuaSuan: return R.image.tabbar.icon_hua_n.cur?.original
    case .ShopCar: return R.image.tabbar.icon_car_n.cur?.original
    case .UserCenter: return R.image.tabbar.icon_user_n.cur?.original
    default: fatalError("unknown tab page, fuck you")
    }
  }
  func selectedImage(_ route: Route) -> UIImage? {
    switch route {
    case .HomePage: return R.image.tabbar.icon_home_h.cur?.original
    case .HuaSuan: return R.image.tabbar.icon_hua_h.cur?.original
    case .ShopCar: return R.image.tabbar.icon_car_h.cur?.original
    case .UserCenter: return R.image.tabbar.icon_user_h.cur?.original
    default: fatalError("unknown tab page, fuck you")
    }
  }

  func configChange() {
    // tabBar.barTintColor = .white
    // tabBar.backgroundColor = .white
    // tabBar.backgroundImage =
    //
    // item.title
    // item.setTitleTextAttributes([.font:UIFont.boldSystemFont(ofSize: 14),.foregroundColor:UIColor.black], for: .normal)
    // item.setTitleTextAttributes([.font:UIFont.boldSystemFont(ofSize: 14),.foregroundColor:UIColor.black], for: .selected)
    //
    // item.image
    // item.selectedImage
    //
    // item.badgeValue = "10"
    // item.badgeColor = .red
    // item.setBadgeTextAttributes([.font:UIFont.boldSystemFont(ofSize: 14),.foregroundColor:UIColor.white], for: .normal)
    // item.setBadgeTextAttributes([.font:UIFont.boldSystemFont(ofSize: 14),.foregroundColor:UIColor.white], for: .selected)

    chg.theme { [weak self] _ in
      guard let self = self else { return }
      self.tabBar.barTintColor = .tab_background
      self.tabBar.backgroundColor = .tab_background
      self.tabBar.backgroundImage = UIColor.tab_background.img
      self.segs.forEach {
        let item = $0.value.tabBarItem
        item?.setTitleTextAttributes([.font: UIFont.tab_title, .foregroundColor: UIColor.tab_title_n as Any], for: .normal)
        item?.setTitleTextAttributes([.font: UIFont.tab_title, .foregroundColor: UIColor.tab_title_h as Any], for: .selected)
        item?.image = self.image($0.key)
        item?.selectedImage = self.selectedImage($0.key)
      }
    }
    chg.language { [weak self] _ in
      guard let self = self else { return }
      self.segs.forEach {
        let item = $0.value.tabBarItem
        item?.title = self.title($0.key)
      }
    }
  }

  override var childForStatusBarStyle: UIViewController? {
    (selectedViewController as? UINavigationController)?.viewControllers.last
  }

}


// [COLORS]
extension UIColor {
  static var tab_background: UIColor { [UIColor(hex: 0xf6f8fc), UIColor(hex: 0x14233a)][THEME.rawValue] }
  static var tab_title_n: UIColor { [UIColor(hex: 0x828ea1), UIColor(hex: 0x6a7a97)][THEME.rawValue] }
  static var tab_title_h: UIColor { [UIColor(hex: 0x2489f1), UIColor(hex: 0x2489f1)][THEME.rawValue] }
}
// [FONTS]
extension UIFont {
  static let tab_title = UIFont.systemFont(ofSize: 9, weight: .bold)
}
