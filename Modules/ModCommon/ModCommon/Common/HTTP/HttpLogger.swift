//
//  HttpLogger.swift
//  ModCommon
//
//  Created by Kevin Wu on 2022/1/1.
//

import UIKit
import Alamofire

#if DEBUG

class HttpLogger {

  static let shared = HttpLogger()

  func begin(_ url: String, _ method: String, _ headers: [String:String]?, _ body: String?) -> Int? {
    queue.sync { [weak self] in
      guard let self = self else { return nil }
      let n = self.counter()
      let entry = Entry(id: n, url: url, method: method, headers: headers, body: body)
      self.entries.append(entry)
      print("=>:[\(n)] \(method) \(url)")
      self.dump()
      return n
    }
  }

  func end(_ id: Int?, _ status: Int?, _ response: String?) {
    queue.sync { [weak self] in
      guard let self = self else { return }
      if let i = self.entries.firstIndex(where: { $0.id == id }) {
        var entry = entries[i]
        entries.remove(at: i)
        entry.status = status
        entry.response = response
        entry.endTime = (TIMESTAMP * 1000).i
        print(entry.info)
      }
    }
  }

  var counter: ()->Int = {
    var value = 0
    return { value.inc() }
  }()

  var queue = DispatchQueue(label: "http-logger-queue")

  func dump() {
    guard TIMESTAMP - dumptime > 30 else { return }
    let items = entries.filter { $0.elapsed > 5000 }
    let info = [
      "=>: \(items.count) / \(entries.count)",
      items.map({ "\($0.elapsed/1000)s [\($0.id)] \($0.url)" }).joined(separator: "\n"),
    ]
      .filter { $0.notEmpty }
      .joined(separator: "\n")
    print(info)
    dumptime = TIMESTAMP
  }
  var dumptime = 0.0

  struct Entry: Codable {
    var id: Int
    var url: String
    var method: String
    var headers: [String:String]?
    var body: String?
    var beginTime = (TIMESTAMP * 1000).i

    var status: Int?
    var response: String?
    var endTime: Int?
    var duration: Int? { endTime == nil ? nil : endTime! - beginTime }
    var elapsed: Int { (TIMESTAMP * 1000).i - beginTime }

    var loading: Bool { endTime == nil }

    var info: String {
      """
      ⌜------------------------------------------------------------------------------⌝
      [\(id)] \(url)
      \(method) \(status?.s ?? "--") \(duration?.s.grouped.suffixed("ms") ?? "--")
      \(headers?.map({ "\($0.key): \($0.value)" }).joined(separator: "\n") ?? "--")
      \(body ?? "--")
      \(response ?? "--")
      ⌞______________________________________________________________________________⌟
      """
    }
  }
  var entries: [Entry] = []
}

#endif
