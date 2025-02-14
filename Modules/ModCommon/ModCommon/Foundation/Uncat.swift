//
//  Uncat.swift
//  ModCommon
//
//  Created by Kevin Wu on 2022/1/1.
//

import UIKit

#if DEBUG
// https://developer.apple.com/forums/thread/701313
public func d_queue_label() -> String {
  String(cString: __dispatch_queue_get_label(nil))
}

public func d_obj_addr(_ obj: AnyObject?) -> String? {
  if let obj = obj {
    return String(describing: Unmanaged.passUnretained(obj).toOpaque())
  }
  return nil
}
// String(describing: cb)               <ModCommon.Checkbox: 0x118d04080>
// String(describing: type(of: cb))     Checkbox  *use this way*
// String(describing: Checkbox.self)    Checkbox
public func d_obj_clsname(_ obj: AnyObject?) -> String? {
  if let obj = obj {
    return String(describing: type(of: obj)).split(separator: ",").map({ String($0) }).last
  }
  return nil
}

public func d_write_file(_ path: String, _ str: String?) {
  guard let str = str else { return }
  path_create_file(path)
  let file = FileHandle(forUpdatingAtPath: path)
  _ = try? file?.seekToEnd()
  try? file?.write(contentsOf: (str + "\n").dat)
  try? file?.close()
}
public func d_read_file(_ path: String) -> String? {
  data_read(path)?.str
}
#endif


public var APP_VERSION: String {
  Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
}
public var APP_BUILD: String {
  Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""
}


public extension NSObject {
  func setNeeds(_ sel: Selector) {
    NSObject.cancelPreviousPerformRequests(withTarget: self, selector: sel, object: nil)
    perform(sel, with: nil, afterDelay: 0)
  }
}


public extension Result {
  var isSuccess: Bool {
    if case .success = self {
      return true
    }
    return false
  }
  var isFailure: Bool {
    if case .failure = self {
      return true
    }
    return false
  }
}

public extension URLResponse {
  var isHTTPSuccess: Bool {
    if let response = self as? HTTPURLResponse {
      return (200..<300).contains(response.statusCode)
    }
    return false
  }
}


public extension DispatchQueue {
  static var userInteractive: DispatchQueue {
    .global(qos: .userInteractive)
  }
  static var userInitiated: DispatchQueue {
    .global(qos: .userInitiated)
  }
  static var `default`: DispatchQueue {
    .global(qos: .default)
  }
  static var utility: DispatchQueue {
    .global(qos: .utility)
  }
  static var background: DispatchQueue {
    .global(qos: .background)
  }
  func delay(_ time: Double?, _ handler: VoidCb?) -> DispatchWorkItem? {
    if let handler = handler {
      let item = DispatchWorkItem(block: handler)
      if let time = time, time > 0.0 {
        DispatchQueue.main.asyncAfter(deadline: .now() + time, execute: item)
      } else {
        DispatchQueue.main.async(execute: item)
      }
      return item
    }
    return nil
  }
}
@discardableResult public func masy(_ time: Double? = nil, _ handler: VoidCb?) -> DispatchWorkItem? { // FUNC
  DispatchQueue.main.delay(time, handler)
}
@discardableResult public func uasy(_ time: Double? = nil, _ handler: VoidCb?) -> DispatchWorkItem? { // FUNC
  DispatchQueue.userInitiated.delay(time, handler)
}


@discardableResult
public func zip_files(_ at: String?, _ to: String? = nil) -> Bool { // FUNC
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
