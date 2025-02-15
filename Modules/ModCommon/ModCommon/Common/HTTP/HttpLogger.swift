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

  static let shared: HttpLogger = {
    let ret = HttpLogger()
    ret.loadFromDisk()
    return ret
  }()


  func loadFromDisk() {
//    let begin = TIMESTAMP - 60*60
//    entries = ([Entry].fromFile(pathmk("/Logs/http.json")) ?? [])
//      .filter { $0.beginTime > begin }
  }
  func saveToDisk() {
//    entries.toFile(pathmk("/Logs/http.json"))
  }


  func begin(_ id: String, _ url: String, _ method: String) {
    if entries.none({ $0.id == id }) {
      let order = entries.first?.order ?? 0
      let entry = Entry(order: order+1, id: id, url: url, method: method)
      entries.insert(entry, at: 0)

      let log = "\(method) \(url)"
      print("[HTTP ] \(log)")
    }
  }
  func update(_ id: String, _ headers: [String:String], _ body: String?) {
    if let index = entries.firstIndex(where: { $0.id == id }) {
      var entry = entries[index]
      entry.headers = headers
      entry.body = body
      entries[index] = entry
    }
  }
  func end(_ id: String, _ status: Int?, _ response: String?) {
    if let index = entries.firstIndex(where: { $0.id == id }) {
      var entry = entries[index]
      entry.status = status
      entry.response = response
      entry.endTime = TIMESTAMP
      entries[index] = entry

      let log = """
      ˅˅˅˅˅˅˅˅˅˅˅˅˅˅˅˅˅˅˅˅˅˅˅˅˅˅˅˅˅˅˅˅˅˅˅˅˅˅˅˅˅˅˅˅˅˅˅˅˅˅˅˅˅˅˅˅˅˅˅˅˅˅˅˅˅˅˅˅˅˅˅˅˅˅˅˅˅˅˅˅
      \(entry.text)
      ˄˄˄˄˄˄˄˄˄˄˄˄˄˄˄˄˄˄˄˄˄˄˄˄˄˄˄˄˄˄˄˄˄˄˄˄˄˄˄˄˄˄˄˄˄˄˄˄˄˄˄˄˄˄˄˄˄˄˄˄˄˄˄˄˄˄˄˄˄˄˄˄˄˄˄˄˄˄˄˄
      """
      print("[HTTP ] \(log)")
    }
  }


  @Setted var entries: [Entry] = [] {
    didSet { saveToDisk() }
  }

  struct Entry: Codable {
    var order: Int // 序号
    var id: String // 请求的 uuid
    var url: String
    var method: String
    var beginTime = TIMESTAMP // 开始时间戳
    var beginDate: Date { Date(timeIntervalSince1970: beginTime) }

    var headers: [String:String]?
    var body: String?

    var status: Int?
    var response: String?
    var endTime: Double? // 结束时间戳
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
