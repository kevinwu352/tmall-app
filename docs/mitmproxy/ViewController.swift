//
//  ViewController.swift
//  foo
//
//  Created by Kevin Wu on 10/23/26.
//

import UIKit
// import Network

class ViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .systemTeal
  }

  @IBOutlet weak var label1: UILabel!
  @IBOutlet weak var label2: UILabel!

  func getSession() -> URLSession {
    let config = URLSessionConfiguration.ephemeral

    // 17.0+
    // let proxyEndpoint = NWEndpoint.hostPort(host: "127.0.0.1", port: 8080)
    // let proxyConfig = ProxyConfiguration(httpCONNECTProxy: proxyEndpoint)
    // config.proxyConfigurations = [proxyConfig]
    // <17.0 没测试过
    // let proxyHost = "10.0.1.88"
    // let proxyPort = 8080
    // // Explicitly mapping both HTTP and HTTPS configurations
    // config.connectionProxyDictionary = [
    //   "HTTPEnable": true,
    //   "HTTPProxy": proxyHost,
    //   "HTTPPort": proxyPort,
    //   "HTTPSEnable": true,
    //   "HTTPSProxy": proxyHost,
    //   "HTTPSPort": proxyPort
    // ]

    let session = URLSession(configuration: config)

    return session
  }

  @IBAction func fetchPost(_ sender: Any) {
    label1.text = "--"
    let url = "https://jsonplaceholder.typicode.com/posts/1"
    let task = getSession().dataTask(with: URLRequest(url: URL(string: url)!)) { data, res, err in
      if let data {
        let json = try? JSONSerialization.jsonObject(with: data) as? [String:Any]
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
          self.label1.text = json?["title"] as? String
        }
      } else {
        if let err {
          DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.label1.text = String(describing: err)
          }
        } else {
          DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.label1.text = "unknown error 111"
          }
        }
      }
    }
    task.resume()
  }

  @IBAction func fetchDummy(_ sender: Any) {
    label2.text = "=="
    let url = "https://dummyjson.com/c/a7ba-2423-4ef5-8334"
    let task = getSession().dataTask(with: URLRequest(url: URL(string: url)!)) { data, res, err in
      if let data {
        let json = try? JSONSerialization.jsonObject(with: data) as? [String:Any]
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
          self.label2.text = json?["code"] as? String
        }
      } else {
        if let err {
          DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.label2.text = String(describing: err)
          }
        } else {
          DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.label2.text = "unknown error 222"
          }
        }
      }
    }
    task.resume()
  }

}

