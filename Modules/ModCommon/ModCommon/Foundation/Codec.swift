//
//  Codec.swift
//  ModCommon
//
//  Created by Kevin Wu on 2022/1/1.
//

import UIKit
import CommonCrypto
import CryptoKit

// MARK: Aes

// https://www.splinter.com.au/2019/06/09/pure-swift-common-crypto-aes-encryption/

// let key = "3132333435360000000000000000000000000000000000000000000000000000".hexdat!
//
// let encoded_str = "kevin".dat.ecbEncrypt(key, true)?.hexstr
// print( encoded_str == "cc3d2362588cc94d96b6066d4ba5d413" )
//
// let encoded_dat = "cc3d2362588cc94d96b6066d4ba5d413".hexdat!
// let decoded_str = encoded_dat.ecbDecrypt(key, true)?.str
// print( decoded_str == "kevin" )

// let key = "3132333435360000000000000000000000000000000000000000000000000000".hexdat!
// let iv = "a36700a0ddccc3c884c4c725b71e9872".hexdat!
//
// let encoded_str = "kevin".dat.cbcEncrypt(key, iv, true)?.hexstr
// print( encoded_str == "b335740a3239767dddc8fadb9b18b2fa" )
//
// let encoded_dat = "b335740a3239767dddc8fadb9b18b2fa".hexdat!
// let decoded_str = encoded_dat.cbcDecrypt(key, iv, true)?.str
// print( decoded_str == "kevin" )

public extension Data {
  init(random: Int) { // FUNC
    let bytes = UnsafeMutableRawPointer.allocate(byteCount: random, alignment: 1)
    defer { bytes.deallocate() }
    if CCRandomGenerateBytes(bytes, random) == kCCSuccess {
      self.init(bytes: bytes, count: random)
    } else {
      self.init(count: random)
    }
  }
}

public extension Data {
  func aesECBEncrypt(_ key: Data, _ padding: Bool) -> Data? {
    var options = 0
    options += kCCOptionECBMode
    options += (padding ? kCCOptionPKCS7Padding : 0)
    return crypt(kCCEncrypt, options, key, Data(count: kCCBlockSizeAES128), self)
  }
  func aesECBDecrypt(_ key: Data, _ padding: Bool) -> Data? {
    var options = 0
    options += kCCOptionECBMode
    options += (padding ? kCCOptionPKCS7Padding : 0)
    return crypt(kCCDecrypt, options, key, Data(count: kCCBlockSizeAES128), self)
  }

  func aesCBCEncrypt(_ key: Data, _ iv: Data, _ padding: Bool) -> Data? {
    var options = 0
    //options += kCCOptionECBMode
    options += (padding ? kCCOptionPKCS7Padding : 0)
    return crypt(kCCEncrypt, options, key, iv, self)
  }
  func aesCBCDecrypt(_ key: Data, _ iv: Data, _ padding: Bool) -> Data? {
    var options = 0
    //options += kCCOptionECBMode
    options += (padding ? kCCOptionPKCS7Padding : 0)
    return crypt(kCCDecrypt, options, key, iv, self)
  }

  private func crypt(_ operation: Int,
                     _ options: Int,
                     _ key: Data,
                     _ iv: Data,
                     _ data: Data
  ) -> Data? {
    key.withUnsafeBytes { key_ptr in
      iv.withUnsafeBytes { iv_ptr in
        data.withUnsafeBytes { data_ptr in
          let out_size = data.count + kCCBlockSizeAES128 * 2
          let out_ptr = UnsafeMutableRawPointer.allocate(byteCount: out_size, alignment: 1)
          defer { out_ptr.deallocate() }
          var out_moved = 0
          let status = CCCrypt(CCOperation(operation), CCAlgorithm(kCCAlgorithmAES), CCOptions(options),
                               key_ptr.baseAddress, key.count,
                               iv_ptr.baseAddress,
                               data_ptr.baseAddress, data.count,
                               out_ptr, out_size, &out_moved)
          if status == kCCSuccess {
            return Data(bytes: out_ptr, count: out_moved)
          } else {
            return nil
          }
        }
      }
    }
  }
}


// MARK: Hash
// "" -> ""

public extension Data {
  var md5: String {
    isEmpty ? "" : Insecure.MD5
      .hash(data: self)
      .prefix(Insecure.MD5.byteCount)
      .map { String(format: "%02x", $0) }
      .joined(separator: "")
  }
  var sha1: String {
    isEmpty ? "" : Insecure.SHA1
      .hash(data: self)
      .prefix(Insecure.SHA1.byteCount)
      .map { String(format: "%02x", $0) }
      .joined(separator: "")
  }
}


// MARK: Base64
//  "xxx".dat.base64Encoded().str
// "eHh4".dat.base64Decoded().str
// "" -> ""

public extension Data {
  func base64Encoded(_ options: Base64EncodingOptions = []) -> Data { // FUNC
    base64EncodedData(options: options)
  }
  func base64Decoded(_ options: Base64DecodingOptions = []) -> Data? { // FUNC
    Data(base64Encoded: self, options: options)
  }
}


// MARK: Url Encode
// "" -> ""

public extension String {
  var urlEncoded: String {
    addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed.subtracting(":#[]@!$&'()*+,;=".charset)) ?? self
  }
  var urlDecoded: String {
    removingPercentEncoding ?? self
  }
}


// MARK: QRCode

public extension UIImage {
  var qrcodeDecoded: String? {
    if let image = CIImage(image: self),
       let decoder = CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])
    {
      let features = decoder
        .features(in: image)
        .compactMap { $0 as? CIQRCodeFeature }
      return features.first?.messageString
    }
    return nil
  }
}
