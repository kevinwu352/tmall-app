//
//  NetworkMonitor.swift
//  ModCommon
//
//  Created by Kevin Wu on 2022/1/1.
//

import UIKit
import Combine
import Alamofire

public var NETWORK_STATUS: NetworkReachabilityManager.NetworkReachabilityStatus { NetworkMonitor.shared.status }

public extension NSNotification.Name {
  static let NetworkDidChange = NSNotification.Name("NetworkDidChangeNotification")
}

public class NetworkMonitor {

  public static let shared = NetworkMonitor()


  @Setted public private(set) var status: NetworkReachabilityManager.NetworkReachabilityStatus = .unknown

  var manager: NetworkReachabilityManager?

  public func startMonitoring() {
    guard manager == nil else { return }
    manager = NetworkReachabilityManager() // (host: "www.baidu.com")
    manager?.startListening { [weak self] status in
      switch status {
      case .unknown:
        print("[Commo] network unknown")
      case .notReachable:
        print("[Commo] network not reachable")
      case let .reachable(type):
        switch type {
        case .ethernetOrWiFi:
          print("[Commo] network reachable via wifi")
        case .cellular:
          print("[Commo] network reachable via wwan")
        }
      }
      self?.status = status
      NotificationCenter.default.post(name: .NetworkDidChange, object: nil)
    }
  }

  public func stopMonitoring() {
    manager?.stopListening()
    manager = nil
  }

}


public extension NetworkReachabilityManager.NetworkReachabilityStatus {
  var isReachable: Bool {
    isReachableOnEthernetOrWiFi || isReachableOnCellular
  }

  var isReachableOnEthernetOrWiFi: Bool {
    self == .reachable(.ethernetOrWiFi)
  }

  var isReachableOnCellular: Bool {
    self == .reachable(.cellular)
  }

  var isNetworkError: Bool {
    self == .notReachable
  }
}
