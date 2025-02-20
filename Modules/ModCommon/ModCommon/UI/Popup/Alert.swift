//
//  Alert.swift
//  ModCommon
//
//  Created by Kevin Wu on 2022/1/1.
//

import UIKit

public struct Alert {

  // .default: normal font
  // .cancel: bold font
  // .destructive: normal font + red


  let controller: UIAlertController

  public init(_ title: String?, _ message: String?, _ style: UIAlertController.Style) {
    controller = UIAlertController(title: title, message: message, preferredStyle: style)
  }


  public func info(_ gotit: String?,
                   _ completion: (()->Void)?
  ) {
    controller.addAction(gotit ?? R.string.shared.alert_gotit.cur, .default) { _ in
      completion?()
    }
    MODALTOP?.present(controller, animated: true, completion: nil)
  }

  public func confirm(_ cancel: String?,
                      _ confirm: String?,
                      _ completion: ((Bool)->Void)?
  ) {
    controller.addAction(cancel ?? R.string.shared.alert_cancel.cur, .cancel) { _ in
      completion?(false)
    }
    controller.addAction(confirm ?? R.string.shared.alert_confirm.cur, .default) { _ in
      completion?(true)
    }
    MODALTOP?.present(controller, animated: true, completion: nil)
  }

  public func input(_ text: String?,
                    _ cancel: String?,
                    _ confirm: String?,
                    _ completion: ((Bool,String?)->Void)?
  ) {
    controller.addTextField {
      $0.text = text
    }
    controller.addAction(cancel ?? R.string.shared.alert_cancel.cur, .cancel) { [weak controller] _ in
      completion?(false, controller?.textFields?.first?.text)
    }
    controller.addAction(confirm ?? R.string.shared.alert_confirm.cur, .default) { [weak controller] _ in
      completion?(true, controller?.textFields?.first?.text)
    }
    MODALTOP?.present(controller, animated: true, completion: nil)
  }

  public func option(_ options: [String],
                     _ cancel: String?,
                     _ completion: ((Int?,String?)->Void)?
  ) {
    options.enumerated().forEach { it in
      controller.addAction(it.element, .default) { _ in
        completion?(it.offset, it.element)
      }
    }
    controller.addAction(cancel ?? R.string.shared.alert_cancel.cur, .cancel) { _ in
      completion?(nil, nil)
    }
    MODALTOP?.present(controller, animated: true, completion: nil)
  }

}

extension UIAlertController {
  func addAction(_ title: String?, _ style: UIAlertAction.Style, _ handler: ((UIAlertAction)->Void)?) {
    let action = UIAlertAction(title: title, style: style, handler: handler)
    addAction(action)
  }
}
