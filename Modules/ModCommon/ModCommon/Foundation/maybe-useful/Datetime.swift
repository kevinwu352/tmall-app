//
//  Datetime.swift
//  ModCommon
//
//  Created by Kevin Wu on 2022/1/1.
//

import UIKit

public var TIMESTAMP: Double { Date().timeIntervalSince1970 }

// now.formatted() 用的是系统选择的日期格式
// now.formatted(.dateTime) 9/20/2025, 12:21
// now.formatted(.iso8601) 2025-09-10T04:21:46Z
// now.formatted(date: .complete, time: .complete)

// DateFormatter 不知如何使用系统选择的日期格式
// df.dateStyle = .full
// df.timeStyle = .full
// df.locale = Locale(identifier: "zh_TW") 结果会包含中文
//
// .full:   Thursday, September 11, 2025
// .long:   September 11, 2025
// .medium: Sep 11, 2025
// .short:  11.09.2025
//
// .full:   09:46:57 China Standard Time
// .long:   09:46:57 GMT+8
// .medium: 09:46:57
// .short:  09:46


// print(date)          // time-zone:0
// print(df.str(date))  // time-zone:local
//
// TimeZone.knownTimeZoneIdentifiers
// df.timeZone = TimeZone(identifier: "GMT")
public extension Date {
  // 16_2450_3116
  // 10_0000_0000     ≈ 30 years
  // 10_0000_0000_000 ≈ 30000 years
  init?(ts: Double?) {
    if let ts = ts, ts > 0 {
      self.init(timeIntervalSince1970: ts < 100_0000_0000 ? ts : ts / 1000)
    } else {
      return nil
    }
  }

  func str(_ df: DateFormatter?) -> String {
    (df ?? FULL_dash_colon).string(from: self)
  }

  var start: Date {
    Calendar.current.startOfDay(for: self)
  }
  var yesterday: Date {
    addedDay(-1)
  }
  var tomorrow: Date {
    addedDay(1)
  }
  var startOfMonth: Date {
    let day = Calendar.current.component(.day, from: self)
    return addedDay(-day+1)
  }
  var endOfMonth: Date {
    let month = Calendar.current.component(.month, from: self)
    var it = self
    while Calendar.current.component(.month, from: it) == month {
      it = it.addedDay(1)
    }
    return it.addedDay(-1)
  }

  func added(_ component: Calendar.Component, _ value: Int) -> Date? {
    Calendar.current.date(byAdding: component, value: value, to: self)
  }
  func addedDay(_ value: Int) -> Date {
    Date(timeIntervalSince1970: timeIntervalSince1970 + 86400 * value.d)
  }

  func older(_ date: Date?) -> Date {
    guard let date = date else { return self }
    return self < date ? self : date
  }
  func newer(_ date: Date?) -> Date {
    guard let date = date else { return self }
    return self < date ? date : self
  }

  var isToday: Bool {
    Calendar.current.isDateInToday(self)
  }
  var isYesterday: Bool {
    Calendar.current.isDateInYesterday(self)
  }
  var isTomorrow: Bool {
    Calendar.current.isDateInTomorrow(self)
  }
  func isSameDay(_ date: Date?) -> Bool {
    guard let date = date else { return false }
    return Calendar.current.isDate(self, inSameDayAs: date)
  }

  // date is before day of receiver?
  func isBeforeDay(_ date: Date?) -> Bool {
    guard let date = date else { return false }
    let result = Calendar.current.compare(self, to: date, toGranularity: .day)
    return result == .orderedDescending
  }
  func isSameOrBeforeDay(_ date: Date?) -> Bool {
    guard let date = date else { return false }
    let result = Calendar.current.compare(self, to: date, toGranularity: .day)
    return result == .orderedDescending || result == .orderedSame
  }
  func isAfterDay(_ date: Date?) -> Bool {
    guard let date = date else { return false }
    let result = Calendar.current.compare(self, to: date, toGranularity: .day)
    return result == .orderedAscending
  }
  func isSameOrAfterDay(_ date: Date?) -> Bool {
    guard let date = date else { return false }
    let result = Calendar.current.compare(self, to: date, toGranularity: .day)
    return result == .orderedAscending || result == .orderedSame
  }
}

public extension DateFormatter {
  func str(_ dte: Date?) -> String? {
    guard let dte = dte else { return nil }
    return string(from: dte)
  }
  func dte(_ str: String?) -> Date? {
    guard let str = str, str.notEmpty else { return nil }
    return date(from: str)
  }
}
public extension ISO8601DateFormatter {
  func str(_ dte: Date?) -> String? {
    guard let dte = dte else { return nil }
    return string(from: dte)
  }
  func dte(_ str: String?) -> Date? {
    guard let str = str, str.notEmpty else { return nil }
    return date(from: str)
  }
}


// http://unicode.org/reports/tr35/tr35-6.html#Date_Format_Patterns

public let FULL_dash_colon: DateFormatter = {
  let ret = DateFormatter()
  ret.dateFormat = "yyyy-MM-dd HH:mm:ss"
  ret.locale = Locale(identifier: "en_US_POSIX")
  return ret
}()

public let FULL_slash_colon: DateFormatter = {
  let ret = DateFormatter()
  ret.dateFormat = "yyyy/MM/dd HH:mm:ss"
  ret.locale = Locale(identifier: "en_US_POSIX")
  return ret
}()

public let FULL_8601: ISO8601DateFormatter = {
    let ret = ISO8601DateFormatter()
    ret.formatOptions = [.withInternetDateTime]
    return ret
}()


public let DATE_dash: DateFormatter = {
  let ret = DateFormatter()
  ret.dateFormat = "yyyy-MM-dd"
  ret.locale = Locale(identifier: "en_US_POSIX")
  return ret
}()

public let DATE_slash: DateFormatter = {
  let ret = DateFormatter()
  ret.dateFormat = "yyyy/MM/dd"
  ret.locale = Locale(identifier: "en_US_POSIX")
  return ret
}()


public let TIME_colon: DateFormatter = {
  let ret = DateFormatter()
  ret.dateFormat = "HH:mm:ss"
  ret.locale = Locale(identifier: "en_US_POSIX")
  return ret
}()
