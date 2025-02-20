//
//  HttpManager.swift
//  ModCommon
//
//  Created by Kevin Wu on 2022/1/1.
//

import UIKit
import Combine
import Alamofire

// https://httpbin.org/
//
// json: { "code": 1, "message": "done" }
// https://run.mocky.io/v3/a928d5b2-a0e4-4d98-b3a5-2ce44adf6222
// json: { "code": -20, "message": "invalid username" }
// https://run.mocky.io/v3/6890aa4c-9c2d-4e1d-a2ed-0a65f7d7b323
// json: { "code": -5, "message": "login first" }
// https://run.mocky.io/v3/646f4fa9-776c-4a2a-ab4b-04b20da9497b
// json: { "code": 1, "message": "done", "updatable": true }
// https://run.mocky.io/v3/dcd6d0a8-9f06-4f6d-8b1d-4252740a4054
//
// plain: you did it
// https://run.mocky.io/v3/8644b1f0-a8de-4d3b-a794-9c8ac6ba14a1
// html: <!DOCTYPE html><html lang="en"><body><div>you did it</div></body></html>
// https://run.mocky.io/v3/098d31db-733a-439d-82d1-cdec1c134e66


@discardableResult
public func http_req(path: String,
                     method: String = "GET",
                     parameters: [String:Any]? = nil,
                     headers: [String:String]? = nil,
                     completion: @escaping (URLResponse?,Data?,Error?)->Void
) -> URLSessionDataTask? {
  let addr: String
  let body: Data?
  if method == "POST" {
    addr = path
    body = parameters?.query.dat
  } else {
    addr = path.addedQuery(parameters?.query)
    body = nil
  }
  guard let url = addr.url else { return nil }

#if DEBUG
  let n = HttpLogger.shared.order
  HttpLogger.shared.begin(n, addr, method, headers, body?.str)
#endif
  var req = URLRequest(url: url)
  req.httpMethod = method
  req.allHTTPHeaderFields = headers
  req.httpBody = body
  req.timeoutInterval = 10.0

  let task = URLSession.shared.dataTask(with: req) { dat, res, err in
#if DEBUG
    HttpLogger.shared.end(n, res?.code, err?.localizedDescription ?? dat?.str)
#endif
    completion(res, dat, err)
  }
  task.resume()

  return task
}


open class HttpManager<Status>: BaseObject {

  // private static let manager: HttpManager = { }()
  open class var shared: HttpManager { fatalError("must not call `shared`, fuck you") }


  public var baseUrl = ""

  public func url(_ path: String) -> String {
    if path.hasPrefix("http") {
      return path
    } else {
      return baseUrl.addedPathseg(path)
    }
  }


  public var commonHeaders: [String:String] = [:]

  public func headers(_ newHeaders: [String:String]?) -> HTTPHeaders? {
    let combined: [String:String]
    if let newHeaders = newHeaders {
      combined = commonHeaders.merging(newHeaders) { $1 }
    } else {
      combined = commonHeaders
    }
    return combined.isEmpty ? nil : HTTPHeaders(combined)
  }


  public enum Paraenc {
    case url
    case json
    var value: ParameterEncoding {
      switch self {
      case .url: return URLEncoding.default
      case .json: return JSONEncoding.default
      }
    }
  }
  public var paraenc: Paraenc = .url


  public var timeoutInterval = 10.0
  public var concurrentAmount = 8
  public lazy var config: URLSessionConfiguration = {
    let ret = URLSessionConfiguration.default
    // 超时时间从调用 GET/POST 方法开始算
    // 如果同时发出 10 个任务，每个任务 4 秒才能返回，前 4 个用时 4 秒，中间 4 个用时 4 秒，2 秒后剩下的 2 个任务超时
    ret.timeoutIntervalForRequest = timeoutInterval
    // 并发数量
    ret.httpMaximumConnectionsPerHost = concurrentAmount
    return ret
  }()

  public enum Evaluator {
    // 获取证书
    // openssl s_client -connect api.stackexchange.com:443 </dev/null | openssl x509 -outform DER -out stackexchange.com.der
    //
    // Web API
    // https://api.stackexchange.com/2.2/users?order=desc&sort=reputation&site=stackoverflow
    //
    // 示例
    // "api.stackexchange.com": DisabledTrustEvaluator()            // 能被抓包
    // "api.stackexchange.com": DefaultTrustEvaluator()             // 能被抓包
    // "api.stackexchange.com": PublicKeysTrustEvaluator()          // 不能抓包
    // "api.stackexchange.com": PinnedCertificatesTrustEvaluator()  // 不能抓包
    //
    // 无证书无抓包: ✔ ✔ ✘ ✘
    // 无证书有抓包: ✔ ✔ ✘ ✘
    // 有证书无抓包: ✔ ✔ ✔ ✔
    // 有证书有抓包: ✔ ✔ ✘ ✘
    case disabled, `default`, publicKeys, pinnedCertificates
    var value: ServerTrustEvaluating {
      switch self {
      case .disabled: return DisabledTrustEvaluator()
      case .default: return DefaultTrustEvaluator()
      case .publicKeys: return PublicKeysTrustEvaluator()
      case .pinnedCertificates: return PinnedCertificatesTrustEvaluator()
      }
    }
  }
  public var hostEvaluators: [String:Evaluator] = [:]
  public lazy var trust: ServerTrustManager = {
    let ret = ServerTrustManager(allHostsMustBeEvaluated: true,
                                 evaluators: hostEvaluators.mapValues { $0.value }
    )
    return ret
  }()

  public lazy var session: Session = {
    let ret = Session(configuration: config, serverTrustManager: trust)
    return ret
  }()


  public struct Response<T: AnyModel> {
    public var raw: Jobj
    public var code: Int?
    public var message: String?
    public var data: Any?
    public var err: HttpError?
    public var object: T?
    public var status: Status?
    public init(raw: Jobj = [:],
                code: Int? = nil,
                message: String? = nil,
                data: Any? = nil,
                err: HttpError? = nil
    ) {
      self.raw = raw
      self.code = code
      self.message = message
      self.data = data
      self.err = err
      object = data != nil ? .init(any: data) : nil
    }
    public var isSuccess: Bool { err == nil }
  }

  public static func publish<T: AnyModel>(path: String,
                                          method: String = "GET",
                                          parameters: [String:Any]? = nil,
                                          paraenc: Paraenc? = nil,
                                          headers: [String:String]? = nil,
                                          object: T.Type = T.self,
                                          queue: DispatchQueue = .main
  ) -> AnyPublisher<Response<T>,Never> {
#if DEBUG
    let n = HttpLogger.shared.order
#endif
    return shared.session.request(shared.url(path),
                                  method: HTTPMethod(rawValue: method.uppercased()),
                                  parameters: parameters,
                                  encoding: (paraenc ?? shared.paraenc).value,
                                  headers: shared.headers(headers),
                                  interceptor: HttpLoginter(n),
                                  requestModifier: nil)
    .validate()
    .publishData(queue: .userInitiated)
    .map {
#if DEBUG
      HttpLogger.shared.end(n, $0.response?.statusCode, $0.data?.str)
#endif
      let response: Response<T> = shared.parse($0)
      return response
    }
    .receive(on: queue)
    .eraseToAnyPublisher()
  }

  public static func request<T: AnyModel>(path: String,
                                          method: String = "GET",
                                          parameters: [String:Any]? = nil,
                                          paraenc: Paraenc? = nil,
                                          headers: [String:String]? = nil,
                                          object: T.Type = T.self,
                                          queue: DispatchQueue = .main,
                                          completion: @escaping (Response<T>)->Void
  ) {
#if DEBUG
    let n = HttpLogger.shared.order
#endif
    shared.session.request(shared.url(path),
                           method: HTTPMethod(rawValue: method.uppercased()),
                           parameters: parameters,
                           encoding: (paraenc ?? shared.paraenc).value,
                           headers: shared.headers(headers),
                           interceptor: HttpLoginter(n),
                           requestModifier: nil)
    .validate()
    .responseData(queue: DispatchQueue.userInitiated) {
#if DEBUG
      HttpLogger.shared.end(n, $0.response?.statusCode, $0.data?.str)
#endif
      let response: Response<T> = shared.parse($0)
      queue.async { completion(response) }
    }
  }

  open func parse<T: AnyModel>(_ response: AFDataResponse<Data>) -> Response<T> {
    switch response.result {
    case let .success(dat):
      return decode(json_from_data(dat) as? Jobj ?? [:])
    case let .failure(err):
      return .init(err: HttpError(err))
    }
  }

  open func decode<T: AnyModel>(_ raw: Jobj) -> Response<T> {
    .init(raw: raw)
  }

}
