//
//  ObjectTableViewController.swift
//  ModHomePage
//
//  Created by Kevin Wu on 2022/1/1.
//

import UIKit
import Combine
import ModCommon
import SwiftyJSON

class ObjectTableViewController: BaseViewController {
  override func setup() {
    super.setup()
    view.addSubview(valueBtn)
  }
  override func layoutViews() {
    super.layoutViews()
    valueBtn.snp.remakeConstraints { make in
      make.center.equalToSuperview()
    }
  }

  override func bindEvents() {
    super.bindEvents()

    vm.user.$value
      .sink { [weak self] in
        self?.valueBtn.title = $0?.object?.name ?? "--"
      }
      .store(in: &cancellables)

    vm.user.$loading
      .sink {
        if $0 {
          Hud.activity("loading")
        } else {
          Hud.hide(true)
        }
      }
      .store(in: &cancellables)


    _ = vm.transform(.init(
      tap: valueBtn.cmb.tap,
      appear: viewDidAppearPub.eraseToAnyPublisher()
    ))

  }

  lazy var vm = ObjectViewModel()

  lazy var valueBtn: Stybtn = {
    let ret = Stybtn(configuration: .plain())
    ret.style(image: nil,
              title: .init("", .head, .red).high()
    )
    return ret
  }()
}


class ObjectViewModel: BaseObject {

  var user = Prop<Obj<Person>>()

  struct Input {
    let tap: AnyPublisher<Void, Never>
    let appear: AnyPublisher<Void, Never>
  }

  struct Output {
  }

  func transform(_ input: Input) -> Output {

    input.tap.merge(with: input.appear)
      .fallVal { [weak self] in self?.user.begin(nil) }
      .map {
        MainHTTP
          .publish(api: .obj(), object: Obj<Person>.self)
          .eraseToAnyPublisher()
      }
      .switchToLatest()
      .sink { [weak self] in self?.user.end($0.object, $0.err) }
      .store(in: &cancellables)

    return .init()
  }

}


struct Person: AnyModel, Codable {
  var name = ""
  var age = 0
  init() { }
  init(any: Any?) {
    let json = JSON(any: any)
    name = json["name"].stringValue
    age = json["age"].intValue
  }
}
