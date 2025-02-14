//
//  HttpApi.swift
//  ModCommon
//
//  Created by Kevin Wu on 2022/1/1.
//

import UIKit
import Combine

public protocol HttpApi {
  var path: String { get set }
  var method: String { get set }
  var parameters: [String:Any] { get set }
  var paraenc: HttpManager.Paraenc? { get set }
  var headers: [String:String] { get set }
}


public protocol HttpApible {
  associatedtype Api
  static func publish<T: AnyModel>(api: Api, object: T.Type, queue: DispatchQueue) -> AnyPublisher<Response<T>,Never> // FUNC
  static func request<T: AnyModel>(api: Api, object: T.Type, queue: DispatchQueue, completion: @escaping (Response<T>)->Void) // FUNC CLOS
}

public extension HttpApible where Self: HttpManager, Api: HttpApi {
  static func publish<T: AnyModel>(api: Api, object: T.Type = T.self, queue: DispatchQueue = .main) -> AnyPublisher<HttpResponse<T>,Never> { // FUNC
    publish(path: api.path,
            method: api.method,
            parameters: api.parameters,
            paraenc: api.paraenc,
            headers: api.headers,
            object: T.self,
            queue: queue)
  }
  static func request<T: AnyModel>(api: Api, object: T.Type = T.self, queue: DispatchQueue = .main, completion: @escaping (HttpResponse<T>)->Void) { // FUNC CLOS
    request(path: api.path,
            method: api.method,
            parameters: api.parameters,
            paraenc: api.paraenc,
            headers: api.headers,
            object: T.self,
            queue: queue,
            completion: completion)
  }
}
