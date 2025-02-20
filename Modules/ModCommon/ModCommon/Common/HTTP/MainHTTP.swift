//
//  MainHTTP.swift
//  ModCommon
//
//  Created by Kevin Wu on 2022/1/1.
//

import UIKit
import Combine

public class MainHTTP: HttpManager<MainHTTP.ServiceStatus> {

  private static let manager = MainHTTP()
  public override static var shared: MainHTTP { manager }

  override init() {
    super.init()
    baseUrl = "https://run.mocky.io"

#if DEBUG
    hostEvaluators = [
      "run.mocky.io": .disabled,
    ]
#else
    hostEvaluators = [
      "run.mocky.io": .default,
    ]
#endif

    reloadUser(AccountManager.shared.user)
    AccountManager.shared.userHooks["03::main-http::manager"] = { [weak self] in
      self?.reloadUser($0)
    }
  }
  func reloadUser(_ user: UserModel?) {
    commonHeaders["token"] = user?.token
  }


  public enum ServiceStatus: Int {
    case authFailed = 20001
  }
  public var events: [ServiceStatus:VoidCb] = [:]


  public override func decode<T: AnyModel>(_ raw: Jobj) -> Response<T> {
    var response = Response<T>(raw: raw,
                               code: raw["code"] as? Int,
                               message: raw["message"] as? String,
                               data: raw["data"]
    )

    guard let code = response.code else {
      response.err = .serviceError(nil, nil)
      return response
    }
    if let status = ServiceStatus(rawValue: code) {
      response.status = status
      events[status]?()
    }

    guard (200..<300).contains(code) else {
      response.err = .serviceError(code, response.message)
      return response
    }

    // ...

    return response
  }
}


// MARK: Api

public extension MainHTTP {
  struct Api {
    public var path: String
    public var method: String
    public var parameters: [String:Any] = [:]
    public var paraenc: Paraenc? = nil
    public var headers: [String:String] = [:]
    public init(path: String, 
                method: String,
                parameters: [String:Any] = [:],
                paraenc: Paraenc? = nil,
                headers: [String:String] = [:]
    ) { // FUNC
      self.path = path
      self.method = method
      self.parameters = parameters
      self.paraenc = paraenc
      self.headers = headers
    }
  }
  static func publish<T: AnyModel>(api: Api, object: T.Type = T.self, queue: DispatchQueue = .main) -> AnyPublisher<Response<T>,Never> { // FUNC
    publish(path: api.path,
            method: api.method,
            parameters: api.parameters,
            paraenc: api.paraenc,
            headers: api.headers,
            object: object,
            queue: queue)
  }
  static func request<T: AnyModel>(api: Api, object: T.Type = T.self, queue: DispatchQueue = .main, completion: @escaping (Response<T>)->Void) { // FUNC CLOS
    request(path: api.path,
            method: api.method,
            parameters: api.parameters,
            paraenc: api.paraenc,
            headers: api.headers,
            object: object,
            queue: queue,
            completion: completion)
  }
}

public extension MainHTTP.Api {
  static func success() -> Self {
    .init(path: "/v3/dbe087fd-1eaa-4c37-94ce-5ec2e336934c", method: "GET", parameters: [:], paraenc: nil, headers: [:])
  }
  static func failure(_ type: Int) -> Self {
    .init(path: "/v3/6890aa4c-9c2d-4e1d-a2ed-0a65f7d7b323", method: "GET", parameters: ["type":type], paraenc: nil, headers: [:])
  }

  static func obj() -> Self {
    .init(path: "/v3/bb4ec3e6-8772-4295-b5ec-97623ffd2821", method: "GET", parameters: [:], paraenc: nil, headers: [:])
  }
  static func lst() -> Self {
    .init(path: "/v3/65b1de27-85aa-4793-b686-e254660b7b46", method: "POST", parameters: ["k":2], paraenc: nil, headers: ["t":"123"])
  }
}
