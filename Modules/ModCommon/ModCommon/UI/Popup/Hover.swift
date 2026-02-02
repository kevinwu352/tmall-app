//
//  Hover.swift
//  Common
//
//  Created by Kevin Wu on 2022/1/1.
//

import UIKit
import SwiftEntryKit

open class HoverView: BaseView {

  public lazy var attrs: EKAttributes = {
    var ret = EKAttributes()
    ret.name = String(describing: Self.self) + "-" + UUID().uuidString
    return ret
  }()

  // 顺序敏感，用 Comparable 比较时，先声明的 case 较小
  public enum Level: Comparable {
    case lower
    case normal
  }
  public var level: Level = .normal

  // 是否正在显示中，中途被抢占也算显示中
  public var showing = false
  // 是否正在被抢占中
  public var overriding = false

  // 在回调中检查 overriding 属性，判断是正常结束而消失，还是被抢占而临时消失
  public var willAppear: ((HoverView)->Void)?
  public var didAppear: ((HoverView)->Void)?
  public var willDisappear: ((HoverView)->Void)?
  public var didDisappear: ((HoverView)->Void)?

  // 滚轮切换日期，调用 complete(nil)
  // 点 confirm，调用 dismiss(true)/complete(true)，推荐用前者
  // 点 cancel，调用 dismiss(false)/complete(false)，推荐用前者
  // 点 screen，调用 complete(false)，当成 cancel
  public var completion: ((Bool?,HoverView)->Void)?
  // 用户只能做一次决定（滚轮切换不算决定），所以，completion 只能被调用一次
  public func complete(_ confirm: Bool?) {
    print("complete , confirm:\(confirm != nil ? confirm == true ? "true" : "false" : "nil"), \(confirm != nil ? completion != nil ? "clear" : "empty" : "--")")
    completion?(confirm, self)
    if confirm != nil {
      completion = nil
    }
  }

  public func enroll() {
    Hover.shared.enroll(self)
  }
  public func dismiss(_ confirm: Bool?, _ completion: (()->Void)?) {
    guard let name = attrs.name else { return }
    Hover.shared.dismiss(name, confirm, completion)
  }
}


public class Hover {

  public static let shared = Hover()

  public var currentEntry: HoverView? {
    SwiftEntryKit.window?.descendant(HoverView.self)
  }

  public func displaying(_ name: String?) -> Bool {
    SwiftEntryKit.isCurrentlyDisplaying(entryNamed: name)
  }
  public func queuing(_ name: String?) -> Bool {
    queue.contains { $0.attrs.name == name }
  }

  public func enroll(_ view: HoverView) {
    guard !displaying(view.attrs.name) && !queuing(view.attrs.name) else { return }
    // view.showing = false
    // view.overriding = false
    if let old = currentEntry {
      if view.level >= old.level {
        old.overriding = true
        enquque(old)
        display(view)
      } else {
        enquque(view)
      }
    } else {
      display(view)
    }
  }
  func display(_ view: HoverView) {
    var attrs = view.attrs
    attrs.lifecycleEvents = .init(
      willAppear: {
        view.willAppear?(view)
      },
      didAppear: {
        view.didAppear?(view)
        view.showing = true
        view.overriding = false
      },
      willDisappear: {
        view.willDisappear?(view)
      },
      didDisappear: { [weak self] in
        print("disappear, overriding:\(view.overriding), \(view.tag)")
        view.didDisappear?(view)
        if !view.overriding {
          // 每次消失都会调用 didDisappear，分三种情况：
          // 1)正常消失，前面 dismiss 时已经调用 complete，且将 completion 置空，这里没啥副作用
          // 2)点 screen 消失，前面没有调用 complete，这里调用
          // 3)被抢占消失，不应该走到这行逻辑
          view.complete(false)
          self?.dequeue()
        }
      }
    )
    SwiftEntryKit.display(entry: view, using: attrs, presentInsideKeyWindow: false, rollbackWindow: .main)
  }
  public func dismiss(_ name: String, _ confirm: Bool?, _ completion: (()->Void)? = nil) {
    if let entry = currentEntry, entry.attrs.name == name {
      entry.complete(confirm)
      SwiftEntryKit.dismiss(.specific(entryName: name), with: completion)
    } else if let index = queue.firstIndex(where: { $0.attrs.name == name }) {
      let entry = queue.remove(at: index)
      entry.complete(confirm)
      completion?()
      // won't trigger did disappear
    }
  }

  func enquque(_ view: HoverView) {
    if view.showing {
      queue.insert(view, at: 0)
    } else {
      if let i = queue.firstIndex(where: { !$0.showing && ($0.level < view.level) }) {
        queue.insert(view, at: i)
      } else {
        queue.append(view)
      }
    }
  }
  func dequeue() {
    guard let view = queue.first else { return }
    display(view)
    queue.removeFirst()
  }
  var queue: [HoverView] = []
}


public extension EKAttributes {
  mutating func banner() {
    //windowLevel = .statusBar
    position = .top
    precedence = .override(priority: .normal, dropEnqueuedEntries: true)
    displayDuration = .infinity
    positionConstraints.size = .init(width: .ratio(value: 1), height: .intrinsic)
    positionConstraints.verticalOffset = 0
    positionConstraints.safeArea = .empty(fillSafeArea: true)

    screenInteraction = .absorbTouches
    entryInteraction = .absorbTouches
    scroll = .disabled
    //hapticFeedbackType = .none
    //lifecycleEvents = LifecycleEvents()

    displayMode = .current
    entryBackground = .color(color: .hover_background)
    screenBackground = .color(color: .hover_screen)
    //shadow = .none
    //roundCorners = .none
    //border = .none
    statusBar = .current

    entranceAnimation = .slide
    exitAnimation = .slide
    popBehavior = .animated(animation: .slide)
  }
  mutating func sheet() {
    //windowLevel = .statusBar
    position = .bottom
    precedence = .override(priority: .normal, dropEnqueuedEntries: true)
    displayDuration = .infinity
    positionConstraints.size = .init(width: .ratio(value: 1), height: .intrinsic)
    positionConstraints.verticalOffset = 0
    positionConstraints.safeArea = .empty(fillSafeArea: true)
    positionConstraints.keyboardRelation = .bind(offset: .init(bottom: 0, screenEdgeResistance: nil))

    screenInteraction = .absorbTouches
    entryInteraction = .absorbTouches
    scroll = .disabled
    //hapticFeedbackType = .none
    //lifecycleEvents = LifecycleEvents()

    displayMode = .current
    entryBackground = .color(color: .hover_background)
    screenBackground = .color(color: .hover_screen)
    //shadow = .none
    //roundCorners = .none
    //border = .none
    statusBar = .current

    entranceAnimation = .slide
    exitAnimation = .slide
    popBehavior = .animated(animation: .slide)
  }
  mutating func alert() {
    //windowLevel = .statusBar
    position = .center
    precedence = .override(priority: .normal, dropEnqueuedEntries: true)
    displayDuration = .infinity
    positionConstraints.size = .init(width: .intrinsic, height: .intrinsic)
    positionConstraints.verticalOffset = 0
    positionConstraints.safeArea = .empty(fillSafeArea: false)

    screenInteraction = .absorbTouches
    entryInteraction = .absorbTouches
    scroll = .disabled
    //hapticFeedbackType = .none
    //lifecycleEvents = LifecycleEvents()

    displayMode = .current
    entryBackground = .color(color: .init(.clear))
    screenBackground = .color(color: .hover_screen)
    //shadow = .none
    //roundCorners = .none
    //border = .none
    statusBar = .current

    entranceAnimation = .alertIn
    exitAnimation = .alertOut
    popBehavior = .animated(animation: .alertOut)
  }
}

extension EKAttributes.DisplayMode {
  static var current: Self {
    switch THEME {
    case .day: return .light
    case .ngt: return .dark
    }
  }
}

extension EKAttributes.StatusBar {
  static var current: Self {
    switch THEME {
    case .day: return .dark
    case .ngt: return .light
    }
  }
}

extension EKAttributes.Animation {
  static var slide: Self {
    .init(
      translate: .init(duration: 0.15)
    )
  }
  static var alertIn: Self {
    .init(
      transform: .init(value: CGAffineTransform(translationX: 0, y: 60), duration: 0.35, spring: .standard),
      fade: .init(from: 0, to: 1, duration: 0.35)
    )
  }
  static var alertOut: Self {
    .init(
      fade: .init(from: 1, to: 0, duration: 0.35)
    )
  }
}
extension EKAttributes.Animation.Spring {
  static var standard: Self {
    .init(damping: 0.5, initialVelocity: 0)
  }
}


// [COLORS]
extension EKColor {
  static let hover_background = EKColor(light: UIColor(hex: 0xf1f3f8), dark: UIColor(hex: 0x0d1626))
  static let hover_screen = EKColor(light: UIColor(white: 50/255.0, alpha: 0.3), dark: UIColor(white: 0, alpha: 0.5))
}


// MARK: Display Attributes

/** Entry presentation window level */
// public var windowLevel = WindowLevel.statusBar

/** The position of the entry inside the screen */
// public var position = Position.top

/** The display manner of the entry. */
// public var precedence = Precedence.override(priority: .normal, dropEnqueuedEntries: false)

/** Describes how long the entry is displayed before it is dismissed */
// public var displayDuration: DisplayDuration = 2 // Use .infinity for infinite duration

/** The frame attributes of the entry */
// public var positionConstraints = PositionConstraints()
// 安全区：
//   .overridden 视图内容会伸进安全区
//   .empty(fillSafeArea: true) 视图内容不会伸进安全区，是否用背景色填充安全区


// MARK: User Interaction Attributes

/** Describes what happens when the user interacts the screen,
 forwards the touch to the application window by default */
// public var screenInteraction = UserInteraction.forward

/** Describes what happens when the user interacts the entry,
 dismisses the content by default */
// public var entryInteraction = UserInteraction.dismiss

/** Describes the scrolling behaviour of the entry.
 The entry can be swiped out and in with an ability to spring back with a jolt */
// public var scroll = Scroll.enabled(swipeable: true, pullbackAnimation: .jolt)

/** Generate haptic feedback once the entry is displayed */
// public var hapticFeedbackType = NotificationHapticFeedback.none

/** Describes the actions that take place when the entry appears or is being dismissed */
// public var lifecycleEvents = LifecycleEvents()


// MARK: Theme & Style Attributes

/** The display mode of the entry */
// public var displayMode = DisplayMode.inferred

/** Describes the entry's background appearance while it shows */
// 在外部修改时:
//   $0.entryBackground = .color(color: .init(rgb: 0x0000ff))
//   $0.entryBackground = .color(color: .init(UIColor.blue))
// public var entryBackground = BackgroundStyle.clear

/** Describes the background appearance while the entry shows */
// public var screenBackground = BackgroundStyle.clear

/** The shadow around the entry */
// public var shadow = Shadow.none

/** The corner attributes */
// public var roundCorners = RoundCorners.none

/** The border around the entry */
// public var border = Border.none

/** Preferred status bar style while the entry shows */
// public var statusBar = StatusBar.inferred


// MARK: Animation Attributes

/** Describes how the entry animates in */
// public var entranceAnimation = Animation.translation

/** Describes how the entry animates out */
// public var exitAnimation = Animation.translation

/** Describes the previous entry behaviour when a new entry with higher display-priority shows */
// public var popBehavior = PopBehavior.animated(animation: .translation) {
//   didSet {
//     popBehavior.validate()
//   }
// }
