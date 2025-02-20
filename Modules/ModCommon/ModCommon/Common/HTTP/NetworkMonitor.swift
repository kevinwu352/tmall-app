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

  var manager: NetworkReachabilityManager?

  @Setted public private(set) var status: NetworkReachabilityManager.NetworkReachabilityStatus = .unknown

  public func startMonitoring() {
    guard manager == nil else { return }
    manager = NetworkReachabilityManager()
    manager?.startListening { [weak self] status in
      switch status {
      case .unknown:
        print("[common] network unknown")
      case .notReachable:
        print("[common] network not reachable")
      case let .reachable(type):
        switch type {
        case .ethernetOrWiFi:
          print("[common] network reachable via wifi")
        case .cellular:
          print("[common] network reachable via wwan")
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
