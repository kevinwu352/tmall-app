//
//  ThemeManager.swift
//  ModCommon
//
//  Created by Kevin Wu on 2022/1/1.
//

import UIKit
import Combine

public var THEME: Theme { ThemeManager.shared.theme }


public enum Theme: Int, CaseIterable {
  case day // day
  case ngt // night
  public static let `default`: Theme = .day
  public init?(_ code: String?) {
    switch code {
    case "day": self = .day
    case "ngt": self = .ngt
    default: return nil
    }
  }
  public var code: String {
    switch self {
    case .day: return "day"
    case .ngt: return "ngt"
    }
  }
  public var next: Self {
    .init(rawValue: (rawValue + 1) % Self.allCases.count) ?? .day
  }
}

public extension NSNotification.Name {
  static let ThemeDidChange = NSNotification.Name("ThemeDidChangeNotification")
}

public class ThemeManager {

  public static let shared = ThemeManager()

  @Setted public private(set) var theme: Theme

  init() {
    let dark = UITraitCollection.current.userInterfaceStyle == .dark
    let diskCode = Defaults.shared.getString("theme_code")
    print("[Common] theme code befor: \(diskCode ?? "none") (\(dark ? "ngt" : "day"))")
    if let diskCode = diskCode, diskCode.notEmpty, diskCode != "FOLLOW_SYSTEM" {
      // use choosed
      theme = Theme(diskCode) ?? .default
    } else {
      // use system
      theme = dark ? .ngt : .day
    }
    print("[Common] theme code after: \(theme.code)")
  }


  public func changeTo(_ value: Theme?) {
    let toTheme: Theme
    if let value = value {
      toTheme = value
      Defaults.shared.setString(value.code, "theme_code")
    } else {
      toTheme = isSystemDark ? .ngt : .day
      Defaults.shared.setString("FOLLOW_SYSTEM", "theme_code")
    }
    if theme != toTheme {
      theme = toTheme
      NotificationCenter.default.post(name: .ThemeDidChange, object: theme.code)
      ChangeManager.theme.fire()
    }
  }

  public func displayIndex() -> Int {
    let diskCode = Defaults.shared.getString("theme_code")
    if let diskCode = diskCode, diskCode.notEmpty, diskCode != "FOLLOW_SYSTEM" {
      if let thm = Theme(diskCode) {
        if let idx = Theme.allCases.firstIndex(of: thm) {
          return idx
        }
      }
      assertionFailure("find theme failed, should not be here")
    }
    return -1
  }


  public var isSystemDark: Bool {
    UITraitCollection.current.userInterfaceStyle == .dark
  }

}
