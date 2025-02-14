//
//  TigerHTTP.swift
//  ModCommon
//
//  Created by Kevin Wu on 2022/1/1.
//

import UIKit
import Combine

public class TigerHTTP: HttpManager<TigerHTTP.ServiceStatus> {

  private static let manager = TigerHTTP()
  public override static var shared: TigerHTTP { manager }

  override init() {
    super.init()
    baseUrl = "http://192.168.50.127/"
  }


  public enum ServiceStatus: Int {
    case authFailed = 20001
  }
  public var events: [ServiceStatus:VoidCb] = [:]
}


// MARK: Api

public extension TigerHTTP {
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

public extension TigerHTTP.Api {
  static func aaa() -> Self {
    .init(path: "/v3/a928d5b2-a0e4-4d98-b3a5-2ce44adf6222", method: "GET", parameters: [:], paraenc: nil, headers: [:])
  }
  static func bbb(_ type: Int) -> Self {
    .init(path: "/v3/6890aa4c-9c2d-4e1d-a2ed-0a65f7d7b323", method: "GET", parameters: ["type":type], paraenc: nil, headers: [:])
  }
}
