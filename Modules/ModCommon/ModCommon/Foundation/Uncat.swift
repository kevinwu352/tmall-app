//
//  Uncat.swift
//  ModCommon
//
//  Created by Kevin Wu on 2022/1/1.
//

import UIKit

#if DEBUG
// https://developer.apple.com/forums/thread/701313
public func dev_queue_label() -> String {
  String(cString: __dispatch_queue_get_label(nil))
}

// String(describing: cb)               <ModCommon.Checkbox: 0x118d04080>
// String(describing: type(of: cb))     Checkbox
// String(describing: Checkbox.self)    Checkbox
public func dev_obj_clsname(_ obj: AnyObject?) -> String? {
  guard let obj = obj else { return nil }
  return String(describing: type(of: obj)).split(separator: ",").map({ String($0) }).last
}
public func dev_obj_addr(_ obj: AnyObject?) -> String? {
  guard let obj = obj else { return nil }
  return String(describing: Unmanaged.passUnretained(obj).toOpaque())
}

public func dev_read_file(_ path: String) -> String? {
  data_read(path)?.str
}
public func dev_write_file(_ path: String, _ str: String?) {
  guard let str = str else { return }
  path_create_file(path)
  let file = FileHandle(forUpdatingAtPath: path)
  _ = try? file?.seekToEnd()
  try? file?.write(contentsOf: (str + "\n").dat)
  try? file?.close()
}
#endif


// =============================================================================

public extension NSObject {
  func setNeeds(_ sel: Selector) {
    NSObject.cancelPreviousPerformRequests(withTarget: self, selector: sel, object: nil)
    perform(sel, with: nil, afterDelay: 0)
  }
}

public extension DispatchQueue {
  static var userInteractive: DispatchQueue { .global(qos: .userInteractive) }
  static var userInitiated: DispatchQueue { .global(qos: .userInitiated) }
  static var `default`: DispatchQueue { .global(qos: .default) }
  static var utility: DispatchQueue { .global(qos: .utility) }
  static var background: DispatchQueue { .global(qos: .background) }
  @discardableResult
  func delay(_ time: Double?, _ handler: VoidCb?) -> DispatchWorkItem? {
    guard let handler = handler else { return nil }
    let item = DispatchWorkItem(block: handler)
    if let time = time, time > 0.0 {
      asyncAfter(deadline: .now() + time, execute: item)
    } else {
      async(execute: item)
    }
    return item
  }
}

@discardableResult
public func masy(_ time: Double?, _ handler: VoidCb?) -> DispatchWorkItem? {
  DispatchQueue.main.delay(time, handler)
}


// =============================================================================

public extension Result {
  var isSuccess: Bool {
    if case .success = self { return true } else { return false }
  }
  var isFailure: Bool {
    if case .failure = self { return true } else { return false }
  }
}
public extension URLResponse {
  var code: Int? {
    guard let response = self as? HTTPURLResponse else { return nil }
    return response.statusCode
  }
  var isHTTPSuccess: Bool {
    guard let code = code else { return false }
    return (200..<300).contains(code)
  }
}


// =============================================================================

@discardableResult
public func zip_files(_ at: String?, _ to: String?) -> Bool {
  guard let at = at else { return false }
  let to = to ?? at.addedPathext("zip")
  var error: NSError?
  var result = false
  NSFileCoordinator().coordinate(readingItemAt: at.furl, options: [.forUploading], error: &error) { url in
    do {
      try FileManager.default.moveItem(at: url, to: to.furl)
      result = true
    } catch {
      result = false
    }
  }
  return error == nil && result
}

// days / hours / minutes / seconds
public extension BinaryInteger {
  func dhms(_ trim: Bool) -> [(Int,String)] {
    let val = self.i
    var list = [
      (  val / 86400              , "d"),
      ( (val % 86400) / 3600      , "h"),
      (((val % 86400) % 3600) / 60, "m"),
      (((val % 86400) % 3600) % 60, "s"),
    ]
    if trim {
      while list.first?.0 == 0 && list.count > 1 {
        list.removeFirst()
      }
    }
    return list
  }
}


public func withValue<T1, T2>(_ v: T1, _ h: (T1)->T2) -> T2 {
  h(v)
}
