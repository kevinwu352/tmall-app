//
//  BaseViewController.swift
//  ModCommon
//
//  Created by Kevin Wu on 2022/1/1.
//

import UIKit
import Combine

open class BaseViewController: UIViewController, Combinable {

  public lazy var cancellables = Set<AnyCancellable>()

  open override func viewDidLoad() {
    super.viewDidLoad()
    setup()
    layoutViews()
    bindEvents()
    loadData()
    initialized = true
    reload()
    routinePubs["view-did-load"]?.send()
  }

  open override func updateViewConstraints() {
    layoutViews()
    super.updateViewConstraints()
  }

  open func setup() {
    view.chg.backgroundColor(.view_bg)
    setupNavbar()
  }
  open func layoutViews() {
  }
  open func bindEvents() {
  }
  open func loadData() {
  }
  public var initialized = false

  public func setNeedsReload() {
    setNeeds(#selector(reload))
  }
  @objc open func reload() {
  }


  // MARK: Lifecycle

  @Setted open var viewAppearing = false
  @Setted open var viewAppearedEver = false

  open override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    routinePubs["view-will-appear"]?.send()
  }
  open override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    viewAppearing = true
    routinePubs["view-did-appear"]?.send()
  }
  open override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    routinePubs["view-will-disappear"]?.send()
  }
  open override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    viewAppearing = false
    setAppearedEver()
    routinePubs["view-did-disappear"]?.send()
  }
  func setAppearedEver() {
    guard !viewAppearedEver else { return }
    setNeeds(#selector(appearedEver))
  }
  @objc func appearedEver() {
    viewAppearedEver = true
  }

  lazy var routinePubs: [String:PassthroughSubject<Void,Never>] = [:]

  public lazy var viewDidLoadPub: PassthroughSubject<Void,Never> = {
    let ret = PassthroughSubject<Void,Never>()
    routinePubs["view-did-load"] = ret
    return ret
  }()
  public lazy var firstViewDidLoadPub = viewDidLoadPub.combineLatest($viewAppearedEver).mapToEvent { !$1 }

  public lazy var viewWillAppearPub: PassthroughSubject<Void,Never> = {
    let ret = PassthroughSubject<Void,Never>()
    routinePubs["view-will-appear"] = ret
    return ret
  }()
  public lazy var firstViewWillAppearPub = viewWillAppearPub.combineLatest($viewAppearedEver).mapToEvent { !$1 }

  public lazy var viewDidAppearPub: PassthroughSubject<Void,Never> = {
    let ret = PassthroughSubject<Void,Never>()
    routinePubs["view-did-appear"] = ret
    return ret
  }()
  public lazy var firstViewDidAppearPub = viewDidAppearPub.combineLatest($viewAppearedEver).mapToEvent { !$1 }

  public lazy var viewWillDisappearPub: PassthroughSubject<Void,Never> = {
    let ret = PassthroughSubject<Void,Never>()
    routinePubs["view-will-disappear"] = ret
    return ret
  }()
  public lazy var firstViewWillDisappearPub = viewWillDisappearPub.combineLatest($viewAppearedEver).mapToEvent { !$1 }

  public lazy var viewDidDisappearPub: PassthroughSubject<Void,Never> = {
    let ret = PassthroughSubject<Void,Never>()
    routinePubs["view-did-disappear"] = ret
    return ret
  }()
  public lazy var firstViewDidDisappearPub = viewDidDisappearPub.combineLatest($viewAppearedEver).mapToEvent { !$1 }


  // MARK: Pop Gesture

  public var popGestureEnabled = true


  // MARK: Navbar

  public enum NavbarOptions {
    case none
    case added(_ padding: Double?)
    case automatic(_ padding: Double?)
    var padding: Double? {
      switch self {
      case .none: return nil
      case let .added(val): return val
      case let .automatic(val): return val
      }
    }
  }
  public var navbarOptions: NavbarOptions = .automatic(nil)

  func setupNavbar() {
    switch navbarOptions {
    case .none:
      break
    case .added:
      addNavbar()
    case .automatic:
      if parent is UINavigationController {
        addNavbar()
      }
    }

    navbar?.addBackIfNeeded(canPopSelf || canDismissSelf)

    if let padding = navbarOptions.padding {
      navbar?.padding_top = padding
    } else {
      if let prev = presentingViewController, prev.presentedViewController?.modalPresentationStyle != .fullScreen {
        navbar?.padding_top = 0
      } else {
        navbar?.padding_top = STATUS_BAR_HET
      }
    }
  }


  // MARK: State View

  public lazy var stateView: StateView = {
    let ret = StateView()
    ret.container = view
    return ret
  }()


  // MARK: Touch

  public func setupTap(_ to: UIView? = nil) { // FUNC
    (to ?? view)?.addGestureRecognizer(tapRec)
  }
  @objc open func tapped(_ sender: UIGestureRecognizer) {
    guard sender.state == .ended else { return }
  }
  public lazy var tapRec: UITapGestureRecognizer = {
    let ret = UITapGestureRecognizer(target: self, action: #selector(tapped))
    return ret
  }()

  public func setupPress(_ to: UIView? = nil) { // FUNC
    (to ?? view)?.addGestureRecognizer(pressRec)
  }
  @objc open func pressed(_ sender: UIGestureRecognizer) {
  }
  public lazy var pressRec: UILongPressGestureRecognizer = {
    let ret = UILongPressGestureRecognizer(target: self, action: #selector(pressed))
    return ret
  }()


  // MARK: Status Bar

  public var statusBarHidden: Bool? = nil {
    didSet { setNeedsStatusBarAppearanceUpdate() }
  }
  public override var prefersStatusBarHidden: Bool {
    if let statusBarHidden = statusBarHidden {
      return statusBarHidden
    }
    return false
  }

  public var statusBarStyle: UIStatusBarStyle? = nil {
    didSet { setNeedsStatusBarAppearanceUpdate() }
  }
  public override var preferredStatusBarStyle: UIStatusBarStyle {
    if let statusBarStyle = statusBarStyle {
      return statusBarStyle
    }
    return THEME == .ngt ? .lightContent : .darkContent
  }

}
