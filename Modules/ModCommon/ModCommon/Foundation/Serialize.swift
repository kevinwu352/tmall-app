//
//  Serialize.swift
//  ModCommon
//
//  Created by Kevin Wu on 2022/1/1.
//

import UIKit

// MARK: File

public func data_read(_ path: String?) -> Data? {
  if let path = path, path.notEmpty {
    return try? Data(contentsOf: path.furl)
  }
  return nil
}

public func data_write(_ data: Data?, _ path: String?) {
  if let path = path, path.notEmpty {
    let dir = (path as NSString).deletingLastPathComponent
    // create dir if needed
    if !FileManager.default.fileExists(atPath: dir, isDirectory: nil) {
      try? FileManager.default.createDirectory(atPath: dir, withIntermediateDirectories: true, attributes: nil)
    }
    try? data?.write(to: path.furl, options: [])
  }
}


// MARK: Transform

public extension Encodable {
  func toData() -> Data? {
    if let data = try? JSONEncoder().encode(self) {
      return data
    }
    return nil
  }
  func toFile(_ path: String?) {
    if let path = path, path.notEmpty {
      data_write(toData(), path)
    }
  }
  func toJSON() -> Any? {
    json_from_data(toData())
  }
}

public extension Decodable {
  static func fromData(_ data: Data?) -> Self? {
    if let data = data {
      if let object = try? JSONDecoder().decode(Self.self, from: data) {
        return object
      }
    }
    return nil
  }
  static func fromFile(_ path: String?) -> Self? {
    if let path = path, path.notEmpty {
      return fromData(data_read(path))
    }
    return nil
  }
  static func fromJSON(_ json: Any?) -> Self? {
    fromData(json_to_data(json))
  }
}


// MARK: Types

// null
// bool/int/double
// string
// array
// object

// let dict: [String:Any] = [
//   "b-t": true,
//   "b-f": false,
//   "iii": 100,
//   "ddd": 1.2,
//   "sss": "bob",
//   "aaa": [ 1, 2, 3 ],
//   "ooo": [ "a":1, "b":2, "c":3 ],
// ]
// print( json_to_data(map)!.str )
//
// let str = """
//       {"nnn":null,"b-t":true,"b-f":false,"iii":100,"ddd":1.2,"sss":"bob","aaa":[1,2,3],"ooo":{"b":2,"c":3,"a":1}}
//       """
// print( json_from_data(str.dat)! )

public typealias Jary = [Any]

public typealias Jobj = [String : Any]

public func json_from_data(_ data: Data?, _ options: JSONSerialization.ReadingOptions = []) -> Any? { // [F]
  if let data = data, data.notEmpty {
    return json_normalize(try? JSONSerialization.jsonObject(with: data, options: options))
  } else {
    return nil
  }
}

public func json_to_data(_ json: Any?, _ options: JSONSerialization.WritingOptions = []) -> Data? { // [F]
  if let json = json, JSONSerialization.isValidJSONObject(json) {
    return try? JSONSerialization.data(withJSONObject: json, options: options)
  } else {
    return nil
  }
}

public func json_normalize(_ json: Any?) -> Any? {
  if let array = json as? [Any] {
    return array.compactMap { json_normalize($0) }
  } else if let object = json as? [String:Any] {
    return object.compactMapValues { json_normalize($0) }
  } else if let number = json as? NSNumber {
    if number.isBool {
      return json as? Bool
    } else if number.isInt {
      return json as? Int
    } else if number.isDouble {
      return json as? Double
    }
  } else if let string = json as? String {
    return string
  }
  return nil
}

// bool as NSNumber   : is bool/int
// int as NSNumber    : is int
// double as NSNumber : is double
extension NSNumber {
  var isBool: Bool {
    CFGetTypeID(self) == CFBooleanGetTypeID()
  }
  var isInt: Bool {
    [
      CFNumberType.sInt8Type,
      CFNumberType.sInt16Type,
      CFNumberType.sInt32Type,
      CFNumberType.sInt64Type,
      CFNumberType.intType,
      CFNumberType.longType,
      CFNumberType.longLongType,
      CFNumberType.nsIntegerType,
      CFNumberType.charType,
      CFNumberType.shortType,
    ].contains(CFNumberGetType(self))
  }
  var isDouble: Bool {
    [
      CFNumberType.float32Type,
      CFNumberType.float64Type,
      CFNumberType.floatType,
      CFNumberType.doubleType,
      CFNumberType.cgFloatType,
    ].contains(CFNumberGetType(self))
  }
}
