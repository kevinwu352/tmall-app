//
//  AppDelegate.swift
//  TmallApp
//
//  Created by Kevin Wu on 2022/1/1.
//

import UIKit
import Combine
import ModCommon

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

  var cancellables = Set<AnyCancellable>()

  var window: UIWindow?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
#if DEBUG
    print(DOCROOT)
#endif
    print("[App  ] did finish launching")

    AppConfiger.shared.beforeCreateWindow()
    window = UIWindow(frame: UIScreen.main.bounds)
    window?.rootViewController = SplashViewController()
    window?.makeKeyAndVisible()
    AppConfiger.shared.afterCreateWindow()

    run()

    return true
  }

  func run() {
    AppConfiger.shared.beforeLaunch(true)
    window?.rootViewController = RootViewController()
    AppConfiger.shared.afterLaunch(true)

//    [
//      "https://www.baidu.com",
//      "https://www.qq.com",
//      "https://www.yahoo.com",
//      "https://www.bing.com",
//      "https://www.google.com",
//      "https://www.twitter.com",
//      "https://www.facebook.com",
//    ].compactMap { $0.url }
//      .enumerated()
//      .publisher
//      .flatMap {
//        URLSession.shared.dataTaskPublisher(for: $0.element)
//          .catch {
//            Fail(error: $0)
//              .delay(for: .seconds(2), scheduler: RunLoop.main)
//              .eraseToAnyPublisher()
//          }
//          .retry(3)
//          .map { $0.response.isHTTPSuccess }
//          .replaceError(with: false)
//          .timeout(.seconds(10), scheduler: RunLoop.main)
//          .replaceEmpty(with: nil)
//          .print("site-\($0.offset)")
//          .eraseToAnyPublisher()
//      }
//      .contains(true)
//      .sink { [weak self] value in
//        AppConfiger.shared.beforeLaunch(value)
////        if value {
////          print("[App  ] show main page, network: \(value)")
////          self?.window?.rootViewController = RootViewController()
////        } else {
////          print("[App  ] show failure page, network: \(value)")
////          self?.window?.rootViewController = FailureViewController()
////        }
//        self?.window?.rootViewController = RootViewController()
//        AppConfiger.shared.afterLaunch(value)
//      }
//      .store(in: &cancellables)
  }


  func applicationDidBecomeActive(_ application: UIApplication) {
    print("[App  ] did become active")
  }

  func applicationWillResignActive(_ application: UIApplication) {
    print("[App  ] will resign active")
  }


  func applicationWillEnterForeground(_ application: UIApplication) {
    print("[App  ] will enter foreground")
    endBackgroundTask()
  }

  func applicationDidEnterBackground(_ application: UIApplication) {
    print("[App  ] did enter background")
    beginBackgroundTask()
  }


  func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
    print("[App  ] open url:\(url), options:\(options)")

    return true
  }


  var backgroundTaskIdentifier: UIBackgroundTaskIdentifier = .invalid
  func beginBackgroundTask() {
    print("[App  ] in background, background task begin")
    backgroundTaskIdentifier = UIApplication.shared.beginBackgroundTask { [weak self] in
      print("[App  ] in background, background task expired")
      if let backgroundTaskIdentifier = self?.backgroundTaskIdentifier, backgroundTaskIdentifier != .invalid {
        UIApplication.shared.endBackgroundTask(backgroundTaskIdentifier)
        self?.backgroundTaskIdentifier = .invalid
      }
    }
    backgroundTask()
  }
  func endBackgroundTask() {
    print("[App  ] enter foreground, cancel previous background task: \(backgroundTaskIdentifier != .invalid)")
    if backgroundTaskIdentifier != .invalid {
      UIApplication.shared.endBackgroundTask(backgroundTaskIdentifier)
      backgroundTaskIdentifier = .invalid
    }
  }
  func backgroundTask() {
    let time = UIApplication.shared.backgroundTimeRemaining
    print("[App  ] in background, remaining \(time)s")
    if backgroundTaskIdentifier != .invalid {
      if time >= 5 {
        masy(1) { self.backgroundTask() }
      }
    }
  }
}

