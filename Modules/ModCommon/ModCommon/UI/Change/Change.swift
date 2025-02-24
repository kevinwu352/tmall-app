//
//  Change.swift
//  ModCommon
//
//  Created by Kevin Wu on 2022/1/1.
//

import UIKit

class ChangeManager {

  static let theme = ChangeManager()

  static let language = ChangeManager()

#if DEBUG
  init() {
    Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true) { [weak self] _ in self?.log() }
  }
#endif

  struct Entry: Hashable {
    init(_ obj: NSObject) {
      id = ObjectIdentifier(obj)
      raw = obj
    }
    let id: ObjectIdentifier
    weak var raw: NSObject?
#if DEBUG
    var time = TIMESTAMP.i
#endif
    static func == (lhs: Entry, rhs: Entry) -> Bool {
      lhs.id == rhs.id
    }
    func hash(into hasher: inout Hasher) {
      hasher.combine(id)
    }
  }
  var entries: [Entry:[String:(Any)->Void]] = [:]

  func set(_ object: NSObject, _ key: String, _ handler: @escaping (Any)->Void) {
    cleanup()
    let item = entries.first { $0.key.id == ObjectIdentifier(object) }

    let entry = item?.key ?? Entry(object)

    var map = item?.value ?? [:]
    map[key] = handler

    entries[entry] = map
#if DEBUG
    if item?.key == nil { obj_n += 1 }
    if item?.value[key] == nil { han_n += 1 }
#endif
  }

  func fire() {
    cleanup()
    entries.forEach { item in
      item.value.forEach {
        $0.value(item.key.raw as Any)
      }
    }
  }
  func cleanup() {
    entries = entries.filter {
      $0.key.raw != nil
    }
  }

#if DEBUG
  struct Line: CustomStringConvertible, Comparable {
    var time = ""
    var cname = ""
    var vname = ""
    var instance = ""
    var names = ""
    init(_ k: Entry, _ v: any Collection<String>) {
      let custom: (UIView?)->UIView? = {
        let cs = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz".charset.inverted
        var ret = $0
        while (dev_obj_clsname(ret) ?? "").trimmingCharacters(in: cs).hasPrefix("UI") {
          ret = ret?.superview
        }
        return ret
      }
      time = String(format: "[%6d]", TIMESTAMP.i - k.time)
      cname = o2s(k.raw as? UIViewController ?? (k.raw as? UIView)?.owner)
      vname = o2s(custom(k.raw as? UIView))
      instance = o2s(k.raw)
      names = v.joined(separator: ", ")
    }
    func o2s(_ obj: AnyObject?) -> String {
      "[\(dev_obj_clsname(obj) ?? "--"),\(dev_obj_addr(obj) ?? "--")]"
    }
    var description: String {
      [time, cname, vname, instance, names].joined(separator: " ")
    }
    static func < (lhs: Line, rhs: Line) -> Bool {
      if lhs.cname == rhs.cname {
        if lhs.vname == rhs.vname {
          if lhs.instance == rhs.instance {
            return lhs.time < rhs.time
          } else {
            return lhs.instance < rhs.instance
          }
        } else {
          return lhs.vname < rhs.vname
        }
      } else {
        return lhs.cname < rhs.cname
      }
    }
  }
  var obj_n = 0 // ever object count
  var han_n = 0 // ever handler count
  func log() {
    cleanup()
    let items = entries
      .map { Line($0.key, $0.value.keys) }
      .sorted { $0 > $1 }
    print("[change] \(items.count) (\(obj_n):\(han_n)) ========================================")
    items.forEach { print("[change] \($0)") }
  }
#endif
}


// =============================================================================

public class Change<Base> {
  let base: Base
  init(_ base: Base) {
    self.base = base
  }
}

public protocol Changable {
  associatedtype ChangeBase
  var chg: Change<ChangeBase> { get }
}

public extension Changable {
  var chg: Change<Self> { Change(self) }
}

extension NSObject: Changable { }


// =============================================================================

public extension Change where Base: NSObject {

  func theme(_ key: String = "theme", _ h: @escaping (Base)->Void) {
    h(base)
    let cb: (Any)->Void = {
      if let obj = $0 as? Base {
        h(obj)
      }
    }
    ChangeManager.theme.set(base, key, cb)
  }

  func language(_ key: String = "language", _ h: @escaping (Base)->Void) {
    h(base)
    let cb: (Any)->Void = {
      if let obj = $0 as? Base {
        h(obj)
      }
    }
    ChangeManager.language.set(base, key, cb)
  }

  func both(_ key: String = "both", _ h: @escaping (Base)->Void) {
    h(base)
    let cb: (Any)->Void = {
      if let obj = $0 as? Base {
        h(obj)
      }
    }
    ChangeManager.theme.set(base, key, cb)
    ChangeManager.language.set(base, key, cb)
  }

}
