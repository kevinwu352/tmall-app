//
//  HttpProp.swift
//  ModCommon
//
//  Created by Kevin Wu on 2022/1/1.
//

import UIKit
import SwiftyJSON

/*
 sv.headReset(true)

 sv.headHandler = { [weak self] in self?.begin(nil) }
 sv.headEndRefreshing()

 sv.headHandler = { [weak self] in self?.begin(.first) }
 sv.footHandler = { [weak self] in self?.begin(.next) }
 sv.headEndRefreshing()
 sv.footReset(more, more)

 .map { () -> AnyPublisher<HttpResponse<Obj<Person>>,Never> in
   MainHTTP
     .publish(api: .obj(), object: Obj<Person>.self)
     .eraseToAnyPublisher()
 }
*/

public protocol Ret: AnyModel {
  associatedtype Model: AnyModel
  var list: [Model] { get set }
  var more: Bool { get set }
}
public extension Ret {
  var object: Model? { list.first }
}

public struct Obj<T: AnyModel>: Ret {
  public var list: [T] = []
  public var more = false
  public init(any: Any?) {
    list = [T(any: any)]
  }
}

public struct Lst<T: AnyModel>: Ret {
  public var list: [T] = []
  public var more = false
  public init(any: Any?) {
    let json = JSON(any: any)
    list = [T](any: json["list"])
    more = json["total"].intValue > json["page"].intValue * json["size"].intValue
  }
}

public enum Pager {
  // nil, obj
  // >=1, lst, xxx page
  // <=0, lst, next page
  case page(_ i: Int)
  public static let first: Pager = .page(1)
  public static let next: Pager = .page(0)
  public var val: Int {
    switch self {
    case let .page(i): return i
    }
  }
  public func calc(_ current: Int) -> Int {
    let i = val
    if i >= 1 {
      return i
    } else {
      return current + 1
    }
  }
}
public class Prop<T: Ret>: BaseObject {
  @Setted public var loading = false
  public var doneEver: Bool { value != nil }

  @Setted public var value: T? {
    didSet { filter.raw = value?.list ?? [] }
  }
  @Setted public var error: HttpError?

  public var object: T.Model? { value?.object }
  public var list: [T.Model]? { value?.list }
  public var listv: [T.Model] { value?.list ?? [] }
  public var more: Bool? { value?.more }
  public var morev: Bool { value?.more ?? false }

  public class Filter {
    public var raw: [T.Model] = [] {
      didSet { run() }
    }
    public var text: String? {
      didSet { run() }
    }
    public var handler: ((T.Model,String?)->Bool)? {
      didSet { run() }
    }
    public func run() {
      if let h = handler {
        list = raw.filter { h($0, text) }
      } else {
        list = raw
      }
    }
    public var list: [T.Model] = []
  }
  public lazy var filter = Filter()

  public var page = 0
  public var pending = 0

  public var timeouter = Timeouter(.day(1))

  public func begin(_ pg: Pager?) {
    loading = true
    pending = pg?.calc(page) ?? 0
  }
  public func end(_ o: T?, _ e: HttpError?) {
    error = e
    if error == nil {
      var obj = o
      if pending > 0 {
        page = pending
        let old = value?.list ?? []
        let new = obj?.list ?? []
        obj?.list = pending == 1 ? new : old + new
      } else {
        // ...
      }
      value = obj
      timeouter.renew()
    }

    loading = false
  }
  public func reset() {
    value = nil
    error = nil

    page = 0
    pending = 0

    timeouter.reset()

    loading = false
  }
}
