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

  var order: Int {
    queue.sync { counter() }
  }
  var counter: ()->Int = {
    var value = 0
    return { value.inc() }
  }()

  func begin(_ id: Int?, _ url: String?, _ method: String?, _ headers: [String:String]?, _ body: String?) {
    queue.sync {
      if let id = id {
        let entry = Entry(id: id, url: url, method: method, headers: headers, body: body)
        entries.append(entry)
        print("=>:[\(id)] \(method ?? "--") \(url ?? "--")")
        dump()
      }
    }
  }

  func end(_ id: Int?, _ status: Int?, _ response: String?) {
    queue.sync {
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

  var queue = DispatchQueue(label: "http-logger-queue")

  func dump() {
    guard TIMESTAMP - dumptime > 30 else { return }
    let items = entries.filter { $0.elapsed > 5000 }
    let info = [
      "=>: \(items.count) / \(entries.count)",
      items.map({ "\($0.elapsed/1000)s [\($0.id)] \($0.url ?? "--")" }).joined(separator: "\n"),
    ]
      .filter { $0.notEmpty }
      .joined(separator: "\n")
    print(info)
    dumptime = TIMESTAMP
  }
  var dumptime = 0.0

  struct Entry: Codable {
    var id: Int
    var url: String?
    var method: String?
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
      [\(id)] \(url ?? "--")
      \(method ?? "--") \(status?.s ?? "--") \(duration?.s.grouped.suffixed("ms") ?? "--")
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

class HttpLoginter: @unchecked Sendable, RequestInterceptor {
  let order: Int
  init(_ n: Int) {
    order = n
  }
  func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, any Error>) -> Void) {
#if DEBUG
    HttpLogger.shared.begin(order,
                            urlRequest.url?.absoluteString,
                            urlRequest.method?.rawValue,
                            urlRequest.allHTTPHeaderFields,
                            urlRequest.httpBody?.str)
#endif
    completion(.success(urlRequest))
  }
}
