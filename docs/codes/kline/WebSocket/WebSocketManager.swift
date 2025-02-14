//
//  WebSocketManager.swift
//  AppCommon
//
//  Created by Kevin Wu on 2022/1/1.
//

import UIKit
import Combine
import Starscream

open class WebSocketManager: BaseObject {

  var url: String?
  var retryTimes = 0
  var socket: WebSocket?

  enum Status {
    case unknown
    case connecting
    case connected
    case failed
    case disconnected
    var shouldRecover: Bool {
      self == .connecting || self == .connected || self == .failed
    }
  }
  var status: Status = .unknown
  var reconnectWhenBack = false

  public init(_ url: String) {
    self.url = url
    super.init()
    bindEvents()
  }


  public func resetUrl(_ url: String?) {
    self.url = url
    connect(true)
  }

  public func connect(_ force: Bool) {
    guard url?.notEmpty == true else { return }
    if force || status != .connected {
      cancelDelayOpenSocket()
      retryTimes = 0
      closeSocket()
      status = .connecting
      delayOpenSocket(0.25)
    }
  }

  public func disconnect() {
    cancelDelayOpenSocket()
    retryTimes = 0
    closeSocket()
    status = .disconnected
  }


  func retryOpenSocket() {
    if (retryTimes < 20) {
      retryTimes += 1
      let timing: (Double)->Double = { 1 - pow(1 - $0, 3) } // https://easings.net/#easeOutCubic
      let delay = timing(Double(retryTimes) / 20) * 5
      logver("retry after \(delay)s \(retryTimes)/20", "WS")
      delayOpenSocket(delay)
    } else {
      logver("won't retry again", "WS")
      retryTimes = 0;
      status = .failed
    }
  }


  var openSocketWork: DispatchWorkItem?
  func delayOpenSocket(_ time: Double) {
    openSocketWork?.cancel()
    openSocketWork = DispatchQueue.main.delay(time) { [weak self] in self?.openSocket() }
  }
  func cancelDelayOpenSocket() {
    openSocketWork?.cancel()
    openSocketWork = nil
  }


  func openSocket() {
    if let url = URL(string: url ?? "") {
      logver("to open: \(url)", "WS")
      var request = URLRequest(url: url)
      request.timeoutInterval = 10
      socket = WebSocket(request: request)
      socket?.delegate = self
      socket?.connect()
    } else {
      assertionFailure("url is empty, should not be here")
    }
  }
  func closeSocket() {
    socket?.delegate = nil
    socket?.disconnect()
    socket = nil
  }


  public struct Entry {
    public var key: String
    public var subscribe: String
    public var unsubscribe: String
    public var times: Int
    public var publisher: Any
  }
  public var entries: [String:Entry] = [:]
  public func addEntry<T>(_ key: String, _ subscribe: String, _ unsubscribe: String) -> PassthroughSubject<T,Never> {
    if var entry = entries[key] {
      entry.times += 1
      let publisher = entry.publisher as? PassthroughSubject<T,Never> ?? PassthroughSubject<T,Never>()
      entry.publisher = publisher
      entries[key] = entry
      return publisher
    } else {
      let publisher = PassthroughSubject<T,Never>()
      let entry = Entry(key: key, subscribe: subscribe, unsubscribe: unsubscribe, times: 1, publisher: publisher)
      entries[key] = entry
      send(subscribe)
      return publisher
    }
  }
  public func removeEntry(_ key: String) {
    if let entry = entries[key] {
      if entry.times <= 1 {
        entries[key] = nil
        send(entry.unsubscribe)
      } else {
        var val = entry
        val.times -= 1
        entries[key] = val
      }
    }
  }
  func restoreEntries() {
    entries.values
      .filter { $0.times > 0 }
      .forEach { send($0.subscribe) }
  }


  func bindEvents() {
    NetworkMonitor.shared.$status
      .debounce(for: .seconds(2), scheduler: DispatchQueue.main)
      .sink { [weak self] in
        guard let self = self else { return }
        if $0.isReachable {
          if self.status.shouldRecover {
            self.connect(true)
          }
        }
      }
      .store(in: &cancellables)

    NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)
      .sink { _ in logver("will enter foreground", "WS") }
      .store(in: &cancellables)

    NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)
      .sink { _ in logver("did enter background", "WS") }
      .store(in: &cancellables)

    NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)
      .sink { [weak self] _ in
        logver("will resign active", "WS")
        guard let self = self else { return }
        if self.status.shouldRecover {
          self.reconnectWhenBack = true
        }
        self.disconnect()
      }
      .store(in: &cancellables)

    NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)
      .debounce(for: .seconds(2), scheduler: DispatchQueue.main)
      .sink { [weak self] _ in
        logver("did become active", "WS")
        guard let self = self else { return }
        if self.reconnectWhenBack == true {
          self.reconnectWhenBack = false
          self.connect(true)
        }
      }
      .store(in: &cancellables)
  }


  func send(_ val: String) {
    if status == .connected {
      socket?.write(string: val) { logver("did write: \(val)", "WS") }
    }
  }

  open func recv(_ val: Data) {
  }

}

extension WebSocketManager: WebSocketDelegate {

  public func didReceive(event: WebSocketEvent, client: WebSocket) {
    switch event {
    case let .connected(headers):
      logver("received connected: \(headers)", "WS")
      status = .connected
      restoreEntries()
    case let .disconnected(reason, code):
      logver("received disconnected: \(reason) \(code)", "WS")
      status = .disconnected

    case let .text(txt):
      logver("received text: \(txt)", "WS")
      recv(txt.dat)
    case let .binary(dat):
      logver("received data: \(dat.count)", "WS")
      recv(dat)

    case let .error(err):
      if let err = err {
        logver("received error: \(err.localizedDescription)", "WS")
      } else {
        logver("received error: nil", "WS")
      }
      closeSocket()
      retryOpenSocket()
    case .cancelled:
      logver("received cancelled", "WS")
      closeSocket()
      status = .failed

    case let .ping(dat):
      if let dat = dat {
        logver("received ping: \(dat.count)", "WS")
      } else {
        logver("received ping: nil", "WS")
      }
    case let .pong(dat):
      if let dat = dat {
        logver("received pong: \(dat.count)", "WS")
      } else {
        logver("received pong: nil", "WS")
      }

    case let .viabilityChanged(value):
      logver("received viability changed: \(value)", "WS")
    case let .reconnectSuggested(value):
      logver("received reconnect suggested: \(value)", "WS")
    }
  }

}
