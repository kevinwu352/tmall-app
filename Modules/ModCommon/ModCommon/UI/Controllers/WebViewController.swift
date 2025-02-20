//
//  WebViewController.swift
//  ModCommon
//
//  Created by Kevin Wu on 2022/1/1.
//

import UIKit
import Combine
import WebKit
import SnapKit

//<!DOCTYPE html>
//<html>
//<body>
//  <button style="font-size:48px;" onclick="eb()">empty body</button>
//  <button style="font-size:48px;" onclick="wb()">with body</button>
//  <script>
//  function eb() {
//    window.webkit.messageHandlers.emptyBody.postMessage({});
//  }
//  function wb() {
//    window.webkit.messageHandlers.withBody.postMessage({"name":"kevin", "age":18});
//  }
//  </script>
//</body>
//</html>

public var COMMON_WEB_HANDLERS: [String:(WKScriptMessage,WKWebView?)->Void] = [:]


class WebViewController: BaseViewController {

  override func setup() {
    super.setup()
    view.addSubviews([webView, progressView])
    view.sendSubviewToBack(progressView)
    view.sendSubviewToBack(webView)
  }
  override func layoutViews() {
    super.layoutViews()
    webView.snp.remakeConstraints { make in
      make.leading.trailing.bottom.equalToSuperview()
      if let navbar = navbar, !navbar.isHidden {
        make.top.equalTo(navbar.snp.bottom)
      } else {
        make.top.equalToSuperview()
      }
    }
    progressView.snp.remakeConstraints { make in
      make.leading.trailing.top.equalTo(webView)
    }
  }
  override func bindEvents() {
    super.bindEvents()
    webView.publisher(for: \.title)
      .sink { [weak self] in
        self?.navbar?.titleLabel.text = $0
      }
      .store(in: &cancellables)

    webView.publisher(for: \.estimatedProgress)
      .sink { [weak self] in
        self?.progressView.progress = Float($0)
        self?.progressView.isHidden = $0 > 0.99
      }
      .store(in: &cancellables)
  }
  override func reload() {
    super.reload()
    guard initialized else { return }

    if let url = url?.url {
      webView.load(URLRequest(url: url))
    }
  }


  func clearAllCaches() {
    WKWebsiteDataStore.default().removeData(ofTypes: [WKWebsiteDataTypeDiskCache, WKWebsiteDataTypeMemoryCache],
                                            modifiedSince: Date(timeIntervalSince1970: 0),
                                            completionHandler: { })
  }


  var url: String? {
    didSet { setNeedsReload() }
  }

  lazy var webView: WKWebView = {
    let configuration = WKWebViewConfiguration()
    configuration.userContentController = WKUserContentController()
    let ret = WKWebView(frame: .zero, configuration: configuration)
    delegate.webView = ret
    return ret
  }()

  lazy var progressView = UIProgressView(progressViewStyle: .bar)

  lazy var delegate = WebContentDelegate()


  deinit {
    delegate.removeAllHandlers()
    print("[common] web view controller deinit")
  }
}

extension WebViewController: Routable {
  func routeUpdate(_ param: Jobj) {
    url = param["url"] as? String
  }
}


class WebContentDelegate: NSObject, WKScriptMessageHandler {

  weak var webView: WKWebView? {
    willSet { removeAllHandlers() }
    didSet { COMMON_WEB_HANDLERS.forEach { add($0.key, $0.value) } }
  }


  var handlers: [String:(WKScriptMessage,WKWebView?)->Void] = [:]

  func add(_ name: String, _ handler: @escaping (WKScriptMessage,WKWebView?)->Void) {
    guard name.notEmpty else { return }
    if handlers.updateValue(handler, forKey: name) == nil {
      webView?.configuration.userContentController.add(self, name: name)
    }
  }
  func remove(_ name: String) {
    guard name.notEmpty else { return }
    if handlers.removeValue(forKey: name) != nil {
      webView?.configuration.userContentController.removeScriptMessageHandler(forName: name)
    }
  }
  func removeAllHandlers() {
    handlers.keys.forEach { webView?.configuration.userContentController.removeScriptMessageHandler(forName: $0) }
    handlers = [:]
  }


  func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
    handlers[message.name]?(message, webView)
  }


  deinit {
    print("[common] web content delegate deinit")
  }
}
