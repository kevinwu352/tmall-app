//
//  UIImageExt.swift
//  ModCommon
//
//  Created by Kevin Wu on 2022/1/1.
//

import UIKit

public extension UIImage {
  var original: UIImage {
    withRenderingMode(.alwaysOriginal)
  }
  var template: UIImage {
    withRenderingMode(.alwaysTemplate)
  }
}

public extension CGSize {
  // aspect fit / aspect fill
  func ratio(_ limit: CGSize, _ fit: Bool) -> Double {
    fit ? min(limit.width / width, limit.height / height) : max(limit.width / width, limit.height / height)
  }
}
public extension UIImage {
  func scaleToFill(_ limit: CGSize) -> UIImage {
    UIGraphicsImageRenderer(size: limit).image {
      draw(in: $0.format.bounds)
    }
  }

  func scaleAspectFit(_ limit: CGSize) -> UIImage {
    let ratio = size.ratio(limit, true)
    let sz = CGSize(width: size.width * ratio, height: size.height * ratio)
    return UIGraphicsImageRenderer(size: sz).image {
      draw(in: $0.format.bounds)
    }
  }

  func scaleAspectFill(_ limit: CGSize) -> UIImage {
    let ratio = size.ratio(limit, false)
    let rt = CGRect(x: (limit.width - size.width * ratio) / 2.0,
                    y: (limit.height - size.height * ratio) / 2.0,
                    width: size.width * ratio,
                    height: size.height * ratio)
    return UIGraphicsImageRenderer(size: limit).image { _ in
      draw(in: rt)
    }
  }
}

public extension UIImage {
  var qrcode: String? {
    if let decoder = CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: [CIDetectorAccuracy: CIDetectorAccuracyHigh]),
       let image = CIImage(image: self)
    {
      let features = decoder
        .features(in: image)
        .compactMap { $0 as? CIQRCodeFeature }
      return features.first?.messageString
    }
    return nil
  }
}
public extension String {
  func qrcode(_ size: CGSize) -> UIImage? {
    if let filter = CIFilter(name: "CIQRCodeGenerator") {
      filter.setValue(dat, forKey: "inputMessage")
      filter.setValue("H", forKey: "inputCorrectionLevel") // L:7% / M:15% / Q:25% / H:30%
      if let image = filter.outputImage {
        let transformed = image.transformed(by: CGAffineTransform(scaleX: size.width / image.extent.size.width, y: size.height / image.extent.size.height))
        return UIImage(ciImage: transformed)
      }
    }
    return nil
  }
}
