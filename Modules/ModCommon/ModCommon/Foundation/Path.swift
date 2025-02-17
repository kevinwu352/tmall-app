//
//  Path.swift
//  ModCommon
//
//  Created by Kevin Wu on 2022/1/1.
//

import UIKit

/*
 /Users/shared/
 /Users/shared/Caches/
 /Users/shared/options

 /Users/kevin/
 /Users/kevin/Caches/
 /Users/kevin/options
 /Users/kevin/user

 /Caches/
 /options
 /defaults
 */


// MARK: Path

public let DOCROOT = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first ?? "" // [G]

public func pathmk(_ trail: String, _ uid: String?) -> String {
  if let uid = uid, uid.notEmpty {
    return DOCROOT.addedPathseg(["Users", uid].joined(separator: "/")).addedPathseg(trail)
  } else {
    return DOCROOT.addedPathseg(trail)
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
  var query: [String:String] {
    (split(separator: "?").last ?? "")
      .split(separator: "&")
      .map { $0.split(separator: "=", omittingEmptySubsequences: false).map({ $0.str }) }
      .filter { $0.count == 2 }
      .reduce([String:String]()) { $0.set($1[1], $1[0]) }
  }
}
public extension Dictionary {
  var query: String {
    mapValues { "\($0)".urlEncoded }
      .map { "\($0.key)=\($0.value)" }
      .joined(separator: "&")
  }
}
