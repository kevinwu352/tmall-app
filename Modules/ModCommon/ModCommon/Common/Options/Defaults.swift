//
//  Defaults.swift
//  ModCommon
//
//  Created by Kevin Wu on 2022/1/1.
//

import UIKit

public class Defaults {

  public static let shared = Defaults(pathmk("/defaults", nil))

  public let path: String
  public private(set) var raw: [String:Any] {
    didSet { work = queue.delay(1) { [weak self] in self?.synchronize() } }
  }
  var work: DispatchWorkItem? {
    didSet { oldValue?.cancel() }
  }
  let queue: DispatchQueue

  public init(_ p: String) {
    path = p
    path_create_file(path)

    if let data = data_read(path),
       let aeskey = aeskey, let aesiv = aesiv, let decrypted = data.aesCBCDecrypt(aeskey, aesiv, true),
       let obj = json_from_data(decrypted) as? Jobj
    {
      print("[Common] defaults load, \(decrypted.str)")
      self.raw = obj
    } else {
      print("[Common] defaults load, __")
      self.raw = [:]
    }

    self.queue = DispatchQueue(label: "defaults-queue-\(path.dat.md5)", attributes: .concurrent)
  }

  func synchronize() {
    if let data = json_to_data(raw),
       let aeskey = aeskey, let aesiv = aesiv, let encrypted = data.aesCBCEncrypt(aeskey, aesiv, true)
    {
      print("[Common] defaults save, \(data.str)")
      data_write(encrypted, path)
    }
  }

  let aeskey = "780153a809b071961c6c490c863da3c4076615ec3559509df3d6b8adf40d06ac".hexdat
  let aesiv = "8a9d75c79eac3fa388fd105c1f73bc53".hexdat
}

public extension Defaults {
  func getBool(_ key: String) -> Bool? {
    queue.sync { raw[key] as? Bool }
  }
  func setBool(_ value: Bool?, _ key: String) {
    queue.async(flags: .barrier) { [weak self] in self?.raw[key] = value }
  }

  func getInt(_ key: String) -> Int? {
    queue.sync { raw[key] as? Int }
  }
  func setInt(_ value: Int?, _ key: String) {
    queue.async(flags: .barrier) { [weak self] in self?.raw[key] = value }
  }

  func getDouble(_ key: String) -> Double? {
    queue.sync { raw[key] as? Double }
  }
  func setDouble(_ value: Double?, _ key: String) {
    queue.async(flags: .barrier) { [weak self] in self?.raw[key] = value }
  }

  func getString(_ key: String) -> String? {
    queue.sync { raw[key] as? String }
  }
  func setString(_ value: String?, _ key: String) {
    queue.async(flags: .barrier) { [weak self] in self?.raw[key] = value }
  }

  func getObject<T: Decodable>(_ key: String) -> T? {
    queue.sync { T.fromJSON(raw[key]) }
  }
  func setObject<T: Encodable>(_ value: T?, _ key: String) {
    queue.async(flags: .barrier) { [weak self] in self?.raw[key] = value?.toJSON() }
  }
}
