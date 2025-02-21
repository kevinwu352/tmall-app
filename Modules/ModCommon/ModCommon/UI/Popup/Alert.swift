//
//  Alert.swift
//  ModCommon
//
//  Created by Kevin Wu on 2022/1/1.
//

import UIKit

public struct Alert {

  public static func info(title: String?,
                          message: String?,
                          gotit: String? = nil,
                          completion: (()->Void)?
  ) {
    let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
    ac.addAction(gotit ?? R.string.shared.alert_gotit.cur, .default) { _ in
      completion?()
    }
    MODALTOP?.present(ac, animated: true, completion: nil)
  }

  public static func confirm(title: String?,
                             message: String?,
                             cancel: String? = nil,
                             confirm: String? = nil,
                             completion: ((Bool)->Void)?
  ) {
    let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
    ac.addAction(cancel ?? R.string.shared.alert_cancel.cur, .cancel) { _ in
      completion?(false)
    }
    ac.addAction(confirm ?? R.string.shared.alert_confirm.cur, .default) { _ in
      completion?(true)
    }
    MODALTOP?.present(ac, animated: true, completion: nil)
  }

  public static func input(title: String?,
                           message: String?,
                           text: String?,
                           cancel: String? = nil,
                           confirm: String? = nil,
                           completion: ((Bool,String?)->Void)?
  ) {
    let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
    ac.addTextField {
      $0.text = text
    }
    ac.addAction(cancel ?? R.string.shared.alert_cancel.cur, .cancel) { [weak ac] _ in
      completion?(false, ac?.textFields?.first?.text)
    }
    ac.addAction(confirm ?? R.string.shared.alert_confirm.cur, .default) { [weak ac] _ in
      completion?(true, ac?.textFields?.first?.text)
    }
    MODALTOP?.present(ac, animated: true, completion: nil)
  }

  public static func option(title: String?,
                            message: String?,
                            options: [String],
                            cancel: String? = nil,
                            completion: ((Int?,String?)->Void)?
  ) {
    let ac = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
    options.enumerated().forEach { it in
      ac.addAction(it.element, .default) { _ in
        completion?(it.offset, it.element)
      }
    }
    ac.addAction(cancel ?? R.string.shared.alert_cancel.cur, .cancel) { _ in
      completion?(nil, nil)
    }
    MODALTOP?.present(ac, animated: true, completion: nil)
  }

}

extension UIAlertController {
  func addAction(_ title: String?, _ style: UIAlertAction.Style, _ handler: ((UIAlertAction)->Void)?) {
    let action = UIAlertAction(title: title, style: style, handler: handler)
    addAction(action)
  }
}
