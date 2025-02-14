//
//  Path.swift
//  ModCommon
//
//  Created by Kevin Wu on 2022/1/1.
//

import UIKit

// /Users/shared/
//   Caches/
//   options
//
// /Users/kevin/
//   Caches/
//   options
//   user
//
// /Caches/
// /options
// /defaults
// /Logs/http.json


// MARK: Path

public func pathmk(_ trail: String, _ uid: String? = nil) -> String { // FUNC
  let base = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first ?? ""
  if let uid = uid, uid.notEmpty {
    return base.addedPathseg(["Users", uid].joined(separator: "/")).addedPathseg(trail)
  } else {
    return base.addedPathseg(trail)
  }
}

public func path_create_directory(_ path: String?) {
  guard let path = path else { return }
  if !FileManager.default.fileExists(atPath: path, isDirectory: nil) {
    try? FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
  }
}
public func path_create_file(_ path: String?) {
  guard let path = path else { return }
  let dir = (path as NSString).deletingLastPathComponent
  if !FileManager.default.fileExists(atPath: dir, isDirectory: nil) {
    try? FileManager.default.createDirectory(atPath: dir, withIntermediateDirectories: true, attributes: nil)
  }
  if !FileManager.default.fileExists(atPath: path, isDirectory: nil) {
    FileManager.default.createFile(atPath: path, contents: nil, attributes: nil)
  }
}
public func path_delete(_ path: String?) {
  guard let path = path else { return }
  try? FileManager.default.removeItem(atPath: path)
}


// MARK: Path Component

public extension String {
  var lastPathseg: String {
    (self as NSString).lastPathComponent
  }
  // addedPathseg("/Logs/http.json")
  func addedPathseg(_ seg: String) -> String {
    guard seg.notEmpty else { return self }
    if hasSuffix("/") && seg.hasPrefix("/") {
      return self + seg.dropFirst()
    } else if !hasSuffix("/") && !seg.hasPrefix("/") {
      return self + "/" + seg
    } else {
      return self + seg
    }
  }
  func addedPathext(_ ext: String) -> String {
    guard ext.notEmpty else { return self }
    var lead = self
    while lead.hasSuffix("/") || lead.hasSuffix(".") {
      lead.removeLast()
    }
    var trai = ext
    while trai.hasPrefix(".") {
      trai.removeFirst()
    }
    return lead + "." + trai
  }
}


// MARK: Url Query

public extension String {
  func addedQuery(_ query: String) -> String {
    guard query.notEmpty else { return self }
    if contains("?") {
      if hasSuffix("?") || hasSuffix("&") {
        return self + query
      } else {
        return self + "&" + query
      }
    } else {
      return self + "?" + query
    }
  }
}

public extension String {
  // key 不解码，value 会解码
  var query: [String:String] {
    var dict: [String:String] = [:]
    split("?")
      .last?
      .split("&")
      .map { $0.split("=") }
      .filter { $0.count == 2 && $0[0].notEmpty }
      .forEach { dict[$0[0]] = $0[1].urlDecoded }
    return dict
  }
}
public extension Dictionary {
  // key 不编码，value 会编码
  var query: String {
    filter { "\($0.key)".notEmpty }
      .mapValues { "\($0)".urlEncoded }
      .map { "\($0.key)=\($0.value)" }
      .joined(separator: "&")
  }
}


// MARK: Url

public extension URL {
  var hst: String? {
    if #available(iOS 16.0, *) {
      return host()
    } else {
      return host
    }
  }
  var qur: String? {
    if #available(iOS 16.0, *) {
      return query()
    } else {
      return query
    }
  }
}
public extension String {
  var hst: String {
    url?.hst ?? self
  }
  var qur: String {
    url?.qur ?? self
  }
}

public extension URL {
  var isDir: Bool {
    (try? resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory == true
  }
}
