//
//  StateView.swift
//  ModCommon
//
//  Created by Kevin Wu on 2022/1/1.
//

import UIKit
import Combine
import SnapKit

public class StateView: BaseView {

  public override func reload() {
    super.reload()
    guard initialized else { return }

    if filled {
      removeSelfFromView()
    } else {
      addSelfToViewIfNeeded()
      removeAllSubviews()
      let view: UIView
      if loading {
        view = loadingStyle.view()
      } else {
        if error {
          view = errorStyle.view()
        } else {
          view = emptyStyle.view()
        }
      }
      addSubview(view)
      view.snp.remakeConstraints { make in
        make.edges.equalToSuperview()
      }
    }
  }


  public weak var container: UIView?

  public var loadingStyle: LoadingStyle = .common
  // filled
  public var emptyStyle: EmptyStyle = .common
  public var errorStyle: ErrorStyle = .common

  public var loading: Bool = false {
    didSet { setNeedsReload() }
  }
  public var filled: Bool = false {
    didSet { setNeedsReload() }
  }
  // empty
  public var error: Bool = false {
    didSet { setNeedsReload() }
  }

  public lazy var refreshEvent = PassthroughSubject<Void,Never>()


  func addSelfToViewIfNeeded() {
    guard let container = container else { return }
    container.addSubview(self)
    snp.remakeConstraints { make in
      if let container = container as? UIScrollView {
        make.edges.equalTo(container.frameLayoutGuide)
      } else {
        make.edges.equalToSuperview()
      }
    }
    superview?.bringSubviewToFront(self)
  }

  func removeSelfFromView() {
    removeAllSubviews()
    removeFromSuperview()
  }


  // swallow touches
  public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
  }

}
