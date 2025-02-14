//
//  HttpError.swift
//  ModCommon
//
//  Created by Kevin Wu on 2022/1/1.
//

import UIKit
import Alamofire

public enum HttpError {
  // 一般不提示
  case cancelled
  // 视情况提示
  case networkError
  // 视情况提示，有些错误并没有 HTTP 错误码
  case serverError(_ code: Int?, _ info: String?)
  // 视情况提示，业务错误
  case serviceError(_ code: Int?, _ info: String?)


  public var serverCode: Int? {
    if case let .serverError(code, _) = self {
      return code
    }
    return nil
  }
  public var serviceCode: Int? {
    if case let .serviceError(code, _) = self {
      return code
    }
    return nil
  }
  public var info: String? {
    switch self {
    case let .serverError(_, info):
      return info
    case let .serviceError(_, info):
      return info
    default: return nil
    }
  }


  public var isCancelled: Bool {
    if case .cancelled = self {
      return true
    } else {
      return false
    }
  }
  public var isNetworkError: Bool {
    if case .networkError = self {
      return true
    } else {
      return false
    }
  }
  public var isServerError: Bool {
    if case .serverError = self {
      return true
    } else {
      return false
    }
  }
  public var isServiceError: Bool {
    if case .serviceError = self {
      return true
    } else {
      return false
    }
  }
}

extension HttpError: Equatable {
  public static func == (lhs: HttpError, rhs: HttpError) -> Bool {
    switch (lhs, rhs) {
    case (.cancelled, .cancelled): return true
    case (.networkError, .networkError): return true
    case (.serverError, .serverError): return true
    case (.serviceError, .serviceError): return true
    default: return false
    }
  }
}

extension HttpError: LocalizedError {
  public var errorDescription: String? {
    switch self {
    case .cancelled:
      return ""
    case .networkError:
      return "Network Error"
    case let .serverError(_, info):
      return info
    case let .serviceError(_, info):
      return info
    }
  }
}


extension HttpError {
  init(_ error: AFError) {
    switch error {
    case .explicitlyCancelled:
      self = .cancelled

    case .serverTrustEvaluationFailed:
      self = .serverError(nil, "Server Trust Evaluation Failed")

    case .invalidURL:
      self = .serverError(nil, "Invalid URL")

    case .downloadedFileMoveFailed:
      self = .serverError(nil, "Downloaded File Move Failed")

    case .sessionDeinitialized:
      self = .serverError(nil, "Session Error")
    case .sessionInvalidated:
      self = .serverError(nil, "Session Error")
    case .sessionTaskFailed:
      self = .serverError(nil, "Session Error")

    case .createURLRequestFailed:
      self = .serverError(nil, "Request Error")
    case .createUploadableFailed:
      self = .serverError(nil, "Request Error")
    case .urlRequestValidationFailed:
      self = .serverError(nil, "Request Error")
    case .requestAdaptationFailed:
      self = .serverError(nil, "Request Error")
    case .requestRetryFailed:
      self = .serverError(nil, "Request Error")

    case .multipartEncodingFailed:
      self = .serverError(nil, "Parameter Encode Error")
    case .parameterEncodingFailed:
      self = .serverError(nil, "Parameter Encode Error")
    case .parameterEncoderFailed:
      self = .serverError(nil, "Parameter Encode Error")

    case .responseValidationFailed:
      if let code = error.responseCode {
        self = .serverError(code, "Response Error (\(code))")
      } else {
        self = .serverError(nil, "Response Error")
      }
    case .responseSerializationFailed:
      self = .serverError(nil, "Response Error")
    }
  }
}
