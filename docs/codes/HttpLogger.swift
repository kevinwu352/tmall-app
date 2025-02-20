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
  func begin(_ id: String, _ url: String, _ method: String) {
    if !entries.contains(where: { $0.id == id }) {
      let order = entries.first?.order ?? 0
      let entry = Entry(order: order+1, id: id, url: url, method: method)
      entries.insert(entry, at: 0)

      let log = "\(method) \(url)"
      print("[HTTP] \(log)")
    }
  }
  func update(_ id: String, _ headers: [String:String], _ body: String?) {
    if let i = entries.firstIndex(where: { $0.id == id }) {
      var entry = entries[i]
      entry.headers = headers
      entry.body = body
      entries[i] = entry
    }
  }
  func end(_ id: String, _ status: Int?, _ response: String?) {
    if let i = entries.firstIndex(where: { $0.id == id }) {
      var entry = entries[i]
      entries.remove(at: i)
      entry.status = status
      entry.response = response
      entry.endTime = TIMESTAMP
      let log = """
        ˅˅˅˅˅˅˅˅˅˅˅˅˅˅˅˅˅˅˅˅˅˅˅˅˅˅˅˅˅˅˅˅˅˅˅˅˅˅˅˅˅˅˅˅˅˅˅˅˅˅˅˅˅˅˅˅˅˅˅˅˅˅˅˅˅˅˅˅˅˅˅˅˅˅˅˅˅˅˅˅
        \(entry.text)
        ˄˄˄˄˄˄˄˄˄˄˄˄˄˄˄˄˄˄˄˄˄˄˄˄˄˄˄˄˄˄˄˄˄˄˄˄˄˄˄˄˄˄˄˄˄˄˄˄˄˄˄˄˄˄˄˄˄˄˄˄˄˄˄˄˄˄˄˄˄˄˄˄˄˄˄˄˄˄˄˄
        """
      print("[HTTP] \(log)")
    }
  }

  struct Entry: Codable {
    var order: Int
    var id: String
    var url: String
    var method: String
    var beginTime = TIMESTAMP

    var headers: [String:String]?
    var body: String?

    var status: Int?
    var response: String?
    var endTime: Double?
    var duration: Double? {
      if let endTime = endTime {
        return endTime - beginTime
      } else {
        return nil
      }
    }

    var loading: Bool { endTime == nil }

    var text: String {
      var info = ""

      info += url
      info += "\n\(method)"
      if let status = status {
        info += " \(status)"
      }
      if let duration = duration {
        info += " \((duration*1000).i)ms"
      }

      info += "\n"
      info += (headers ?? [:])
        .map { "\($0.key): \($0.value)" }
        .joined(separator: "\n")

      info += "\n"
      info += (body ?? "")

      info += "\n"
      info += (response ?? "")

      return info
    }
  }
  var entries: [Entry] = []
}

extension HttpLogger: EventMonitor {
  func request(_ request: Request, didCreateURLRequest urlRequest: URLRequest) {
    begin(request.id.uuidString,
          urlRequest.url?.absoluteString ?? "--",
          urlRequest.httpMethod ?? "--")
  }
  func request(_ request: Request, didCreateTask task: URLSessionTask) {
    update(request.id.uuidString,
           task.currentRequest?.allHTTPHeaderFields ?? [:],
           task.originalRequest?.httpBody?.str)
  }
  func request<Value>(_ request: DataRequest, didParseResponse response: DataResponse<Value, AFError>) {
    end(request.id.uuidString,
        response.response?.statusCode,
        response.data?.str ?? response.error?.localizedDescription)
  }
}

#endif
