//
//  Utils.swift
//  ModCommon
//
//  Created by Kevin Wu on 2022/1/1.
//

import UIKit

public enum Haptic {
  case impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle)
  case notification(_ type: UINotificationFeedbackGenerator.FeedbackType)
  case selection

  public func generate() {
    switch self {
    case let .impact(style):
      let generator = UIImpactFeedbackGenerator(style: style)
      generator.prepare()
      generator.impactOccurred()
    case let .notification(type):
      let generator = UINotificationFeedbackGenerator()
      generator.prepare()
      generator.notificationOccurred(type)
    case .selection:
      let generator = UISelectionFeedbackGenerator()
      generator.prepare()
      generator.selectionChanged()
    }
  }
}


public class Imgsaver: NSObject {
  public static func save(_ image: UIImage, _ completion: ((Error?)->Void)?) { // CLOS
    let n = shared.counter()
    shared.handlers[n] = completion
    UIImageWriteToSavedPhotosAlbum(image, shared, #selector(image(_:didFinishSavingWithError:contextInfo:)), UnsafeMutableRawPointer(bitPattern: n))
  }

  static let shared = Imgsaver()

  var counter: ()->Int = { // CLOS
    var value = 0
    return { value.inc() }
  }()

  var handlers: [Int:(Error?)->Void] = [:] // CLOS

  @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo info: UnsafeRawPointer) {
    let n = Int(bitPattern: info)
    handlers[n]?(error)
    handlers[n] = nil
  }
}


public class Weachecker {
  public static let shared = Weachecker()

  var counter: ()->Int = { // CLOS
    var value = 0
    return { value.inc() }
  }()
  class Entry {
    weak var object: AnyObject?
    var interval: TimeInterval
    var completion: VoidCb
    init(_ obj: AnyObject?, _ int: TimeInterval, _ comp: @escaping VoidCb) {
      object = obj
      interval = int
      completion = comp
    }
  }
  var map: [Int:Entry] = [:]

  public func enroll(_ object: AnyObject?, _ interval: TimeInterval, _ completion: @escaping VoidCb) {
    let n = counter()
    map[n] = Entry(object, interval, completion)
    check(n)
  }
  func check(_ n: Int) {
    guard let entry = map[n] else { return }
    if entry.object == nil {
      map[n] = nil
      DispatchQueue.main.async { entry.completion() }
    } else {
      DispatchQueue.main.asyncAfter(deadline: .now() + entry.interval) { [weak self] in self?.check(n) }
    }
  }
}


public enum Timeint {
  case second(_ n: Int)
  case minute(_ n: Int)
  case hour(_ n: Int)
  case day(_ n: Int)
  case week(_ n: Int)
  public var val: Double {
    switch self {
    case let .second(n): return n.dbl
    case let .minute(n): return n.dbl * 60
    case let .hour(n): return n.dbl * 60 * 60
    case let .day(n): return n.dbl * 24 * 60 * 60
    case let .week(n): return n.dbl * 7 * 24 * 60 * 60
    }
  }
}
public class Timeouter {
  public var time = 0.0
  public var interval: Timeint
  public var expired: Bool { time <= TIMESTAMP }
  public init(_ ti: Timeint) {
    interval = ti
  }
  public func renew() {
    time = TIMESTAMP + interval.val
  }
  public func reset() {
    time = 0
  }
}
