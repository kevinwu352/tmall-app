//
//  ViewController.swift
//  testr
//
//  Created by Kevin Wu on 2/1/26.
//

import UIKit
import CoreBase
//import RswiftResources

extension UIUserInterfaceStyle {
  var name: String {
    switch self {
    case .unspecified: "unspecified"
    case .light: "light"
    case .dark: "dark"
    @unknown default:
      "unknown default"
    }
  }
}

class ViewController: UIViewController {

  var imageView: UIImageView?
  var label: UILabel?

  override func viewDidLoad() {
    super.viewDidLoad()
    print("view did load")
    // Do any additional setup after loading the view.
    view.backgroundColor = .lightGray

    view.addSubview(lb)
    lb.text = name
    lb.sizeToFit()
    lb.center = CGPoint(x: 100, y: 100)

    let iv = doit()
    view.addSubview(iv)
    iv.sizeToFit()
    iv.center = view.center
    imageView = iv

    let v = doit2()
    view.addSubview(v)
    v.sizeToFit()
    v.center = view.center
    label = v
    v.text = .kWelcomeMsg
  }

  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesEnded(touches, with: event)
    print("touch")

    imageView?.image = .kFlatCloud // UIImage(resource: .kFlatCloud)
    imageView?.sizeToFit()

//    let value = view.window?.overrideUserInterfaceStyle
//    print(value?.name)
//    view.window?.overrideUserInterfaceStyle = value == .light ? .dark : .light
    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
      let value = self.view.window?.overrideUserInterfaceStyle
      print(value?.name)
      self.view.window?.overrideUserInterfaceStyle = value == .light ? .dark : .light
    }
    DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
      let value = self.view.window?.overrideUserInterfaceStyle
      print(value?.name)
      self.view.window?.overrideUserInterfaceStyle = value == .light ? .dark : .light
    }
    DispatchQueue.main.asyncAfter(deadline: .now() + 6.0) {
      let value = self.view.window?.overrideUserInterfaceStyle
      print(value?.name)
      self.view.window?.overrideUserInterfaceStyle = value == .light ? .dark : .light
    }


    let old = UserDefaults.standard.value(forKey: "AppleLanguages")
    print(old)
//    if let list = old as? [String] {
//      if let first = list.first {
//        let val = first.hasPrefix("en") ? "fr" : "en"
//        print("\(first) => \(val)")
//        UserDefaults.standard.set([val], forKey: "AppleLanguages")
//        UserDefaults.standard.synchronize()
//      }
//    }


    // https://medium.com/@itsuki.enjoy/localization-in-ios-swift-6b3a7735bd1a
    // 不推荐自己修改语言，推荐的方式是跳转到系统设置里面去修改
//    guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else {return}
//    UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)






    // 回到系统默认
//    UserDefaults.standard.set(nil, forKey: "AppleLanguages")
//    UserDefaults.standard.synchronize()


//    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
//      print("change")
//      self.view.window?.rootViewController = ViewController()
//    }




//    iv.image = UIImage(resource: .)
//    iv.image = R.image.com.flat_cloud_2()
//    iv.image = R.image.com.flat_cloud_2()
  }

  lazy var lb: UILabel = {
    let ret = UILabel()
    return ret
  }()

}

