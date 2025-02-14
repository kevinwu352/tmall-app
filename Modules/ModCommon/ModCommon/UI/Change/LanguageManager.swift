//
//  LanguageManager.swift
//  ModCommon
//
//  Created by Kevin Wu on 2022/1/1.
//

import UIKit
import Combine

public var LANGUAGE: Language { LanguageManager.shared.language }


// https://developer.apple.com/library/archive/documentation/MacOSX/Conceptual/BPInternational/LanguageandLocaleIDs/LanguageandLocaleIDs.html#//apple_ref/doc/uid/10000171i-CH15-SW9
// print(NSLocale.availableLocaleIdentifiers)
//
// Language IDs
//   zh
//   zh-HK
//   zh-Hant
//
// Local IDs
//   zh
//   zh_HK
//   zh-Hant
//   zh-Hant_HK

public enum Language: Int, CaseIterable {
  case en
  case zhHans
  case zhHant
  public static let `default`: Language = .en
  public init?(_ code: String?) {
    switch code {
    case "en": self = .en
    case "zh-Hans": self = .zhHans
    case "zh-Hant": self = .zhHant
    default: return nil
    }
  }
  public var code: String {
    switch self {
    case .en: return "en"
    case .zhHans: return "zh-Hans"
    case .zhHant: return "zh-Hant"
    }
  }
  public var next: Self {
    .init(rawValue: (rawValue + 1) % Self.allCases.count) ?? .en
  }
}

public extension NSNotification.Name {
  static let LanguageDidChange = NSNotification.Name("LanguageDidChangeNotification")
}

public class LanguageManager {

  public static let shared = LanguageManager()

  @Setted public private(set) var language: Language

  init() {
    let diskCode = Defaults.shared.getString("language_code")
    print("[Commo] language code befor: \(diskCode ?? "none") (\(Bundle.main.preferredLocalizations.first ?? "none"))")
    if let diskCode = diskCode, diskCode.notEmpty, diskCode != "FOLLOW_SYSTEM" {
      // use choosed
      language = Language(diskCode) ?? .default
    } else {
      // use system
      language = Language(Bundle.main.preferredLocalizations.first) ?? .default
    }
    print("[Commo] language code after: \(language.code)")
  }


  public func changeTo(_ value: Language?) {
    let toLanguage: Language
    if let value = value {
      toLanguage = value
      Defaults.shared.setString(value.code, "language_code")
    } else {
      toLanguage = Language(Bundle.main.preferredLocalizations.first) ?? .default
      Defaults.shared.setString("FOLLOW_SYSTEM", "language_code")
    }
    if language != toLanguage {
      language = toLanguage
      NotificationCenter.default.post(name: .LanguageDidChange, object: language.code)
      ChangeManager.language.fire()
    }
  }

  public func displayIndex() -> Int {
    let diskCode = Defaults.shared.getString("language_code")
    if let diskCode = diskCode, diskCode.notEmpty, diskCode != "FOLLOW_SYSTEM" {
      if let lan = Language(diskCode) {
        if let idx = Language.allCases.firstIndex(of: lan) {
          return idx
        }
      }
      assertionFailure("find language failed, should not be here")
    }
    return -1
  }


  public func languageName(_ code: String) -> String? {
    NSLocale(localeIdentifier: code).displayName(forKey: .identifier, value: code)
  }

}
