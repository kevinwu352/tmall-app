//
//  Route.swift
//  ModCommon
//
//  Created by Kevin Wu on 2022/1/1.
//

import UIKit

// homepage?7b2273796d626f6c223a22425443227d
// homepage?7b2273796d626f6c223a22425443227d/web?7b2273796d626f6c223a22425443227d


public protocol Routable {
  func routeUpdate(_ param: Jobj)
}


public enum Route {

  case HomePage
  case HuaSuan
  case ShopCar
  case UserCenter

  case Web(url: String?)

  // =============================================================================


  public init?(_ url: String) {
    let comps = url.split(separator: "?", omittingEmptySubsequences: false).map { $0.sup }
    self.init(comps[0], comps.at(1) ?? "")
  }

  public init?(_ name: String, _ query: String) {
    self.init(name, json_from_data(query.hexdat) as? Jobj ?? [:])
  }

  public init?(_ name: String, _ param: Jobj) {
    switch name {

    case "homepage": self = .HomePage
    case "huasuan": self = .HuaSuan
    case "shopcar": self = .ShopCar
    case "usercenter": self = .UserCenter

    case "web": self = .Web(url: param["url"] as? String)

    default: return nil
    }
  }


  public var url: String {
    if let query = query {
      return name + "?" + query
    } else {
      return name
    }
  }

  public var name: String {
    switch self {
    case .HomePage: return "homepage"
    case .HuaSuan: return "huasuan"
    case .ShopCar: return "shopcar"
    case .UserCenter: return "usercenter"

    case .Web: return "web"
    }
  }

  public var query: String? {
    json_to_data(param)?.hexstr
  }
  public var param: Jobj? {
    var param: Jobj = [:]
    switch self {

    case let .Web(url):
      param["url"] = url

    default: break
    }
    return param.isEmpty ? nil : param
  }

}

public extension Route {
  var type: UIViewController.Type? {
    kSavedRoutes[name]
  }
  static func register(_ type: UIViewController.Type?, _ name: String) {
    kSavedRoutes[name] = type
  }
}
fileprivate var kSavedRoutes: [String:UIViewController.Type] = [:]

extension Route: Equatable {
  public static func == (lhs: Route, rhs: Route) -> Bool {
    lhs.name == rhs.name
  }
}

extension Route: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(name)
  }
}
