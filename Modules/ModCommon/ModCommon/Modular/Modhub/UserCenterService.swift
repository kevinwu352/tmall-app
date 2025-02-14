//
//  UserCenterService.swift
//  ModCommon
//
//  Created by Kevin Wu on 2022/1/1.
//

import UIKit

public protocol UserCenterService: Modulable {
  var list: [String] { get }
}
